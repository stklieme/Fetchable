# Fetchable

**Fetchable**  is a Swift protocol extension to make Core Data `NSManagedObject` subclasses more generic (for macOS and iOS). It adds static methods for `NSManagedObject` subclasses to insert, fetch and delete objects without adding extra code to the subclasses except an enum to specify the sorting attribute keys.


**Requirements**:
--

- Swift 4.1
- Xcode 9+
- iOS 8.0+ / macOS 10.10+

**Usage**:
--

- Add `Fetchable.swift` to your project and make all `NSManagedObject` subclasses adopt `Fetchable`.
- Add an enum `AttributeName` to each `NSManagedObject` subclass to specify the sorting attribute keys for example 

        enum AttributeName : String { case name }
        
- `Fetchable` requires a reference to the `NSManagedObjectContext` instance.  
  - If the project uses the default implementation of the Core Data stack in `AppDelegate` you are done.
  - If the Core Data stack is not located in `AppDelegate` add a computed read-only property `managedObjectContext` in `AppDelegate` and return the reference to the managed object context.
  - If you are using Application Extensions which lacks an `AppDelegate` class change the reference directly in the `Fetchable.swift` file.

---

The default method to fetch data is (assuming there is a `NSManagedObject` subclass `Foo`)

    do {
	    let objects = try Foo.objects()
    } catch {
	    print(error)
    }
    
It returns a non-optional array of `Foo` objects (no type cast needed).  
All fetch methods can `throw` by passing through the Core Data error.

---

The objects can be sorted in three ways by

 1. Passing one attribute key (default direction is `ascending`)
 
        let objects = try Foo.objects(sortedBy : .name)
        let objects = try Foo.objects(sortedBy : .index, ascending: false)
  
 2. Passing an (variadic) array of tuples representing the `key` and `ascending` parameters of a sort descriptor respectively
  
        let objects = try Foo.objects(sortedBy : (.name, true), (.index, false))
  
 3. Passing an array of `NSSortDescriptor` instances for more advanced sorting
 
        let objects = try Foo.objects(sortedBy : [NSSortDescriptor(... , NSSortDescriptor(...])
  
---

Other (optional) parameters are 

- A predicate 

      let objects = try Foo.objects(for : NSPredicate(format...)
   
- A fetch limit
 
      let objects = try Foo.objects(fetchLimit : 2)
 
---

A compound filter can be 

 - `let objects = try Foo.objects(for : NSPredicate(format...), sortedBy: .name, fetchLimit : 5`)
 
 This is much more convenient than creating the request, predicate and sort descriptor(s) *manually*.

---
    
There are also corresponding methods to return a single (optional) object
    
    let object = try Foo.object()
    
and a method to get the number of found objects

	let numberOfObjects = try Foo.objectCount()
   
---

The methods to insert a new object, get the entity description and delete all objects are very simple, too.

- `let newFoo = Foo.insertNewObject()`
- `let entityDescription = Foo.entityDescription`
- `Foo.deleteAll()`
