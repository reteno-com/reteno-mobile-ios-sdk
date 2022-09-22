# Database collaboration

## Overview

Realm used as database solution.

All work with DB is incapsulated in the `Core` framework.

Some rules of database collaboration:

- Database objects have internal access level in `Core` (not accessible for other frameworks)
- If collaboration with DB objects should be performed out of `Core` framework (e.g. show object's fields in UI), DB object should be converted into independent plain object (class or struct) to encapsulate DB framework in `Core` and to avoid potential issues with DB objects usage (e.g. access to DB object from incorrect thread). 
Here you can see example of such approach with Realm object `UserObject` and its independent `User` representation:
```
public struct User: Decodable {
    
    public let id: String
    public var userName: String = ""
    public var name: String?
    public var bio: String?
    public var phone: String?
    public var avatar: AppImage?
    
}

final class UserObject: Object, Decodable {
    
    @objc dynamic private(set) var id: String = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var name: String?
    @objc dynamic var bio: String?
    @objc dynamic var phone: String?
    @objc dynamic var avatar: AppImageObject?
    
    override static func primaryKey() -> String? {
        return #keyPath(UserObject.id)
    }
    
    var lightweightRepresentation: User {
        return User(
            id: id,
            userName: userName,
            name: name,
            bio: bio,
            phone: phone,
            avatar: avatar?.lightweightRepresentation
        )
    }
    
}
```

- All work with DB objects (saving, fetching, updating) performed in **services** located in `Core`. Also **Service** is responsible for mapping DB object to the plain representation and send it out to the users of **Service**.
