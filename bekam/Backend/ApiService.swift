import UIKit
import Firebase

class ApiServices {
    
    // get one session
    
    public func getSession(buyerId:String, productId:String, completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let chatApi = ChatApi()
        chatApi.get(buyerId: buyerId, productId: productId, completion: completion)
        
    }
    
    // get last message
    
    public func getLastMessage(sessionId:String,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let chatApi = ChatApi()
        chatApi.getLastMessage(sessionId: sessionId, completion: completion)
        
    }
    
    // add new user

    public func addNewUser(user:AppUser,userId:String,completion:@escaping (DatabaseReference?,Error?)-> Void){
        
        let userApi = UserApi()
        userApi.post(userId: userId, user: user, completion: completion)
    }
    
    
    // send message
    
    public func sendMessage(message:Message,sessionId:String,completion:@escaping (DatabaseReference?,Error?)-> Void){
        
        let chatApi = ChatApi()
        chatApi.post(message: message, sessionId:sessionId, completion: completion)
        
    }
    
    
    // get one product
    
    public func loadProduct(productId:String,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let prodcutApi = ProductsApi()
        prodcutApi.load(productid: productId, completion: completion)
        
    }
    
    // post a new session
    
    public func postSession(session:ChatSession,sellerId:String, completion:@escaping (DatabaseReference?,Error?)-> Void){
        
        let chatApi = ChatApi()
        chatApi.post(session: session, sellerId:sellerId, completion: completion)
        
    }
    
    // load a specific chat messages
    
    public func loadChat(sessionId:String,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let chatApi = ChatApi()
        chatApi.get(sessionId: sessionId, completion: completion)
        
    }
    
    // get all sessions for a user
    
    public func getAllSessionForUser(userId:String,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let chatApi = ChatApi()
        chatApi.get(buyerId: userId, completion: completion)
        
    }
    
    // get user with product id
    
    public func getUser(productId:String,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let userApi = UserApi()
        userApi.get(productId: productId, completion: completion)
        
    }
    
    // get user with id
    
    public func getUser(id:String,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let userApi = UserApi()
        userApi.get(id: id, completion: completion)
        
    }
    
    // load any image with a given url
    
    public func loadImage(url:String,completion: @escaping (Data?,Error?)->Void){
        
        let imageApi = ImageApi()
        imageApi.load(url:url,completion: completion)
        
    }
    
    // load products
    
    public func loadProducts(userId:String = "" ,completion: @escaping (DataSnapshot?,Error?)->Void){
        
        let productsApi = ProductsApi()
        productsApi.load(userId:userId,completion: completion)
        
    }
    
    // update product
    
    public func updateProduct(product:Product, completion:@escaping (DatabaseReference?,Error?)-> Void){
        
        let productsApi = ProductsApi()
        productsApi.update(product: product) { (ref, error) in
            completion(ref,error)
        }
        
    }
    
    // Post product
    
    public func postProduct(price:String, image:UIImage, compressToSize:Double? = 1000, completion: @escaping (DatabaseReference?,Error?)->Void)
    
    {
        
        var compressedImage = image
        
        if compressToSize != 0 || compressToSize != nil {
            compressedImage = compressedImage.resizeToBeLessThan(maxSizeInKB: compressToSize!)
        }
        
        let productsApi = ProductsApi()
        let imageApi = ImageApi()
        
        // post the product without an image
        
        productsApi.post(price: price) { (ref, error) in
            
            // when you get the id store an image in the storage
            
            guard error == nil else {
                print("error posting the product")
                completion(nil,error)
                return
            }
            
            imageApi.post(image: compressedImage, productId: (ref?.key)!, imageName: nil, completion: { (meta, error, _imageName , productId) in
                
                // when completed link the image to the product
                
                guard error == nil else {
                    print("error storing the image")
                    completion(nil,error)
                    return
                }
                
                productsApi.addImageLink(imageName: _imageName!, productId: productId!, completion: { (ref, error) in
                    
                    guard error == nil else {
                        print("error storing the image")
                        completion(nil,error)
                        return
                    }
                    
                    
                    completion(ref!,nil)
                })
                
            })
            
        }
        
    }
    
    
    /// Private things
    
    private static var instance : ApiServices?
    private init () {}
    public static func getInstance() -> ApiServices {
        
        if instance == nil {
            instance = ApiServices()
        }
        return instance!
    }
    
}

fileprivate class ImageApi {
    
    static var imagesCache = NSCache<NSString,NSData>()
    
    func load(url:String, completion: @escaping (Data?,Error?) -> Void) {
        
        // if the image is cached go back
        if let data = ImageApi.imagesCache.object(forKey: url as NSString) {
            print("Image in cash")
            completion(data as Data,nil)
            return
        }
        
        // else
        let imgRef = storageRef.child("\(url)")
        print("url: \(url)")
        
        imgRef.getData(maxSize: 1 * 500 * 500) { data,error in
            
            if data == nil {
                print("error getting image")
                ImageApi.imagesCache.setObject(NSData(), forKey: url as NSString)
                completion(nil,error)
            }else{
                print("go image with url : \(url)")
                ImageApi.imagesCache.setObject(data! as NSData, forKey: url as NSString)
                completion(data,nil)
            }
        }
    }
    
    func post(image:UIImage, productId:String, imageName:String?, completion: @escaping (StorageMetadata?,Error?,String?,String?) -> Void){
        
        let _imageName =
            imageName != nil ? imageName
            :Date().getString(formatString: IMG_NAME_DATE_FORMAT)
        
        let data = image.pngData()
        let imgRef = storageRef.child("images/\(productId)/\(_imageName!).png")
        
        imgRef.putData(data!, metadata: nil) { (metadata, error) in
            completion(metadata,error,_imageName,productId)
        }
    }
    
    
}

fileprivate class ProductsApi {
    
    func load(productid:String,completion: @escaping (DataSnapshot?, Error?) -> Void) {
        
        ref.child("products/\(productid)").observe(.value, with: { (snapshot) in
            completion(snapshot,nil)
        }) { (error) in
            completion(nil,error)
        }
    }
    
    func load(userId:String,completion: @escaping (DataSnapshot?, Error?) -> Void) {
        
        if !userId.isEmpty{
            ref.child("products").queryOrdered(byChild: "userid").queryEqual(toValue:userId).observe(.childAdded, with: { (snapshot) in
                completion(snapshot,nil)
            }) { (error) in
                completion(nil,error)
            }
        }
        
        else {
            ref.child("products").queryOrdered(byChild: "addedDate").observe(.childAdded, with: { (snapshot) in
                completion(snapshot,nil)
            }) { (error) in
                completion(nil,error)
            }
        }
    }
    
    func post(price:String, completion: @escaping (DatabaseReference?, Error?) -> Void) {
        
        let date = Date().getString(formatString: DATE_FORMAT)
        let uid = firUser?.uid
        let available = true
        
        let productInfo : [String:Any] =
            
            [
                "addedDate":date,
                "available":available,
                "price":price,
                "userid":uid,
                ]
        
        ref.child("products").childByAutoId().setValue(productInfo, andPriority: nil) { (error, prRef) in
            
            completion(prRef,error)
            
        }
        
    }
    
    func update(product:Product, completion: @escaping (DatabaseReference?, Error?) -> Void) {
        
        let productInfo : [String:Any] =
            
            [
                "id":product.id,
                "imagesURLS":product.imagesURLS,
                "categories":product.categories,
                "addedDate":product.addedDate?.getString(formatString: DATE_FORMAT),
                "available":product.available,
                "price":"\(product.price)",
                "userid":product.userId,
                "description":product.description,
                "name":product.name,
                "city":product.city
            ]
        
        guard let id = product.id else {
            print("sorry cannot update no id")
            return
        }
        
        ref.child("products").child(id).setValue(productInfo, andPriority: nil) { (error, prRef) in
            print("I am here at the callback !!! Good job ")
            completion(prRef,error)
        }
    
    }
    
    func addImageLink(imageName:String, productId:String, completion: @escaping (DatabaseReference?,Error?) -> Void){
        
        ref.child("products/\(productId)/imagesURLS").setValue(["images/\(productId)/\(imageName).png"], withCompletionBlock: { (error, imgRef) in
            completion(imgRef,error)
        })
    }
    
}

fileprivate class UserApi {
    
    func post(userId:String, user:AppUser, completion: @escaping (DatabaseReference?, Error?) -> Void)
        
    {
        let userInfo = user.toDict()
        ref.child("users/\(userId)").setValue(userInfo) { (err, uRef) in
            
            if err != nil {
                completion(nil,err)
            }
            
            // no error
            
            completion(uRef,nil)
            
        }
    }
    
    func get(id:String,completion: @escaping (DataSnapshot?,Error?) -> Void) {
        
        ref.child("users/\(id)").observe(.value, with: { (snapshot) in
            print("I got the user")
            completion(snapshot,nil)
        }) { (error) in
            print("I did not get the user")
            completion(nil,error)
        }
    }
    
    func get(productId:String,completion: @escaping (DataSnapshot?,Error?) -> Void) {
        
        let userIdRef = ref.child("products").child("\(productId)").child("userid")
        
        userIdRef.observe(.value, with: { (snap) in
            
            if let userId = snap.value as? String {
                
                print("user id for this product is \(userId)")
                
                self.get(id: userId, completion: completion)
                
            }
            
        }) { (err) in
            
            completion(nil,err)
            
        }
    }
    
    
}

fileprivate class ChatApi{
    
    func get(buyerId:String, productId:String, completion: @escaping (DataSnapshot?, Error?) -> Void)
        
    {
        
        ref.child("sessions/\(buyerId)").queryOrdered(byChild: "productId").queryEqual(toValue: productId).observe(.value, with: { (snapshot) in
            
            print("snapshot from api \(snapshot)")
            
            completion(snapshot,nil)
            
            
        }) { (error) in
            
            completion(nil,error)
            
            print("not found")
            
        }
    }
    
    func getLastMessage(sessionId:String, completion: @escaping (DataSnapshot?, Error?) -> Void){
        
        print("sessionID \(sessionId)")
        
        ref.child("messages/\(sessionId)").queryOrdered(byChild: "messageTime").queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            
            completion(snapshot,nil)
            
        }) { (error) in
            
            completion(nil,error)
            
        }
        
    }
    
    
    func get(sessionId:String, completion: @escaping (DataSnapshot?, Error?) -> Void){
        
        print("sessionID \(sessionId)")
        
        let messegesRef = ref.child("messages/\(sessionId)")
        
        messegesRef.observe(.childAdded, with: { (snapshot) in
                        
            completion(snapshot,nil)
            
        }) { (error) in
            
            completion(nil,error)
            
        }
        
    }
    
    func get(buyerId:String, completion: @escaping (DataSnapshot?, Error?) -> Void)
    
    {
       
        ref.child("sessions/\(buyerId)").observe(.childAdded, with: { (snapshot) in
            
            completion(snapshot,nil)
            
        }) { (error) in
            
            completion(nil,error)
            
        }
    }
    
    func post(message: Message, sessionId:String, completion: @escaping (DatabaseReference?, Error?) -> Void)
        
    {
        let messageInfo = message.toDict()
        
        ref.child("messages/\(sessionId)").childByAutoId().setValue(messageInfo) { (err, mRef) in
            
            guard err == nil else {
                completion(nil,err)
                return
            }
            
            completion(mRef,nil)
            
        }
    }
    
    func post(session:ChatSession, sellerId:String, completion: @escaping (DatabaseReference?, Error?) -> Void)
        
    {
        
        // create under the sessions for the buyer
        
        let sessionInfo = session.toDict()
        guard let buyerId = firUser?.uid else { return }
        
        ref.child("sessions/\(buyerId)").childByAutoId().setValue(sessionInfo, andPriority: nil) { (error, sRef) in
            
            // check if there is error
            
            if error != nil {
                completion(nil,error)
                return
            }
            
            // no error add to the seller
            
            let sessionId = sRef.key
            
            ref.child("sessions/\(sellerId)/\(sessionId)").setValue(sessionInfo, andPriority: nil) { (error, sRef) in
                
                if error != nil {
                    completion(nil,error)
                    return
                }
                
                // no error back to user
                
                completion(sRef,nil)
                
                
            }
            
        }
        
        
    }
    
}

