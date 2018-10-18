
//  Fetchable.swift

import CoreData
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif


/// A protocol extension for Core Data NSManagedObject subclasses.

protocol Fetchable
{
    associatedtype FetchableType: NSManagedObject = Self
    associatedtype AttributeName: RawRepresentable
    
    static var entityName : String { get }
    static var entityDescription : NSEntityDescription { get }
    static var managedObjectContext : NSManagedObjectContext { get }
    
    static func objects() throws -> [FetchableType]
    static func objects(for predicate: NSPredicate?, sortedBy: AttributeName?, ascending: Bool, fetchLimit: Int) throws -> [FetchableType]
    static func objects(sortedBy sortDescriptors: [NSSortDescriptor], predicate: NSPredicate?, fetchLimit: Int) throws -> [FetchableType]
    static func objects(sortedBy sortCriteria: (AttributeName, Bool)..., predicate: NSPredicate?, fetchLimit: Int) throws -> [FetchableType]
    
    static func object() throws -> FetchableType?
    static func object(for predicate: NSPredicate?, sortedBy: AttributeName?, ascending: Bool) throws -> FetchableType?
    static func object(sortedBy sortDescriptors: [NSSortDescriptor], predicate: NSPredicate?) throws -> FetchableType?
    static func object(sortedBy sortCriteria: (AttributeName, Bool)..., predicate: NSPredicate?) throws -> FetchableType?
    
    static func objectCount(for predicate: NSPredicate?) throws -> Int
    static func insertNewObject() -> FetchableType
    static func deleteAll() throws
}

extension Fetchable where Self : NSManagedObject, AttributeName.RawValue == String
{
    /// Returns the entity name for the current class.
    
    static var entityName : String {
        return String(describing:self)
    }
    
    
    /// Returns the entity description for the current class.
    
    static var entityDescription : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
    }

    
    /// Returns the current managed object context.
    
    static var managedObjectContext : NSManagedObjectContext {
#if os(iOS)
        return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
#else
        return (NSApp.delegate as! AppDelegate).managedObjectContext
#endif
    }
    
    
    /// Returns the fetched objects of the current entity
    ///
    /// - Returns: A non-optional array of objects of the current NSManagedObject subclass.
    
    static func objects() throws -> [FetchableType] {
        let request = fetchRequest(predicate: nil, sortedBy: nil, ascending:true, fetchLimit: 0)
        return try managedObjectContext.fetch(request)
    }
    
    
    /// Returns the fetched objects of the current entity for the given parameters, sorted by one key
    ///
    /// - Parameters:
    ///   - predicate: The fetch predicate (optional, default is nil).
    ///   - sortedBy: The key to sort the result (optional, default is not sorted).
    ///   - ascending: The sorting direction (optional, default is ascending).
    ///   - fetchLimit: The number of items to be fetched (optional, default is no limit).
    /// - Returns: A non-optional array of objects of the current NSManagedObject subclass.
    
    static func objects(for predicate: NSPredicate? = nil,
                        sortedBy: AttributeName? = nil,
                        ascending: Bool = true,
                        fetchLimit: Int = 0) throws -> [FetchableType]
    {
        let request = fetchRequest(predicate: predicate, sortedBy: sortedBy, ascending: ascending, fetchLimit: fetchLimit)
        return try managedObjectContext.fetch(request)
    }
    
    
    /// Returns the fetched objects of the current entity for the given parameters, sorted by an array of sort descriptors.
    ///
    /// - Parameters:
    ///   - sortDescriptors: an array of sort descriptors.
    ///   - predicate: The fetch predicate (optional, default is nil).
    ///   - fetchLimit: the number of items to be fetched (optional, default is no limit).
    /// - Returns: A non-optional array of objects of the current NSManagedObject subclass.
    
    static func objects(sortedBy sortDescriptors: [NSSortDescriptor],
                        predicate: NSPredicate? = nil,
                        fetchLimit: Int = 0) throws -> [FetchableType]
    {
        let request = fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
        return try managedObjectContext.fetch(request)
    }
    
    /// Returns the fetched objects of the current entity for the given parameters, sorted by an array of tuples representing 'key' and 'ascending' parameter of an NSSortDescriptor.
    ///
    /// - Parameters:
    ///   - sortCriteria: An variadic array of tuples representing 'key' and 'ascending' parameter of an NSSortDescriptor.
    ///   - predicate: The fetch predicate (optional, default is nil).
    ///   - fetchLimit: the number of items to be fetched (optional, default is no limit).
    /// - Returns: A non-optional array of objects of the current NSManagedObject subclass.
    
    
    static func objects(sortedBy sortCriteria: (AttributeName, Bool)...,
                        predicate: NSPredicate? = nil,
                        fetchLimit: Int = 0) throws -> [FetchableType]
    {
        let sortDescriptors = sortCriteria.map{ NSSortDescriptor(key: $0.0.rawValue, ascending: $0.1)  }
        let request = fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
        return try managedObjectContext.fetch(request)
    }
    
    
    /// Returns the first found object of the current entity
    ///
    /// - Returns: The first found object of the current NSManagedObject subclass or nil.
    
    static func object() throws -> FetchableType? {
        let request = fetchRequest(predicate: nil, sortedBy: nil, ascending:true, fetchLimit: 1)
        return try managedObjectContext.fetch(request).first
    }
    
    
    /// Returns the first found object of the current entity for the given parameters, sorted by one key.
    ///
    /// - Parameters:
    ///   - predicate: The fetch predicate (optional, default is nil).
    ///   - sortedBy: The key to sort the result (optional, default is not sorted).
    ///   - ascending: The sorting direction (optional, default is ascending).
    /// - Returns: The first found object of the current NSManagedObject subclass or nil.
    
    static func object(for predicate: NSPredicate? = nil,
                       sortedBy: AttributeName? = nil,
                       ascending: Bool = true) throws -> FetchableType?
    {
        return try objects(for: predicate, sortedBy: sortedBy, ascending: ascending).first
    }
    
    
    /// Returns the first found object of the current entity for the given predicate, sorted by an array of sort descriptors.
    ///
    /// - Parameters:
    ///   - sortDescriptors: An array of sort descriptors.
    ///   - predicate: The fetch predicate (optional, default is nil).
    /// - Returns: The first found object of the current NSManagedObject subclass or nil.
    
    static func object(sortedBy sortDescriptors: [NSSortDescriptor],
                       predicate: NSPredicate? = nil) throws -> FetchableType?
    {
        return try objects(sortedBy: sortDescriptors, predicate: predicate, fetchLimit: 1).first
    }
    
    
    /// Returns the first found object of the current entity for the given predicate, sorted by an array of tuples representing 'key' and 'ascending' parameter of an NSSortDescriptor.
    ///
    /// - Parameters:
    ///   - sortCriteria: An variadic array of tuples representing 'key' and 'ascending' parameter of an NSSortDescriptor.
    ///   - predicate: The fetch predicate (optional, default is nil).
    /// - Returns: The first found object of the current NSManagedObject subclass or nil.
    
    
   static func object(sortedBy sortCriteria: (AttributeName, Bool)...,
                        predicate: NSPredicate? = nil) throws -> FetchableType?
    {
        let sortDescriptors = sortCriteria.map{ NSSortDescriptor(key: $0.0.rawValue, ascending: $0.1)  }
        return try objects(sortedBy: sortDescriptors, predicate: predicate, fetchLimit: 1).first
    }
    
    
    /// Returns the number of fetched objects of the current entity for the given predicate.
    ///
    /// - Parameters:
    ///   - predicate: The fetch predicate (optional, default is nil).
    /// - Returns: The number of objects of the current NSManagedObject subclass matching the criteria.
    
    static func objectCount(for predicate: NSPredicate? = nil) throws -> Int
    {
        let request = fetchRequest(predicate: predicate)
        return try managedObjectContext.count(for: request)
    }
    
    
    /// A Core Data fetch request for the current NSManagedObject subclass for sorting by one key.
    ///
    /// - Parameters:
    ///   - predicate: The fetch predicate (optional, default is nil).
    ///   - sortedBy: The key to sort the result (optional, default is not sorted).
    ///   - ascending: The sorting direction (optional, default is ascending).
    ///   - fetchLimit: The number of items to be fetched (optional, default is no limit).
    /// - Returns: The fetch request for the current NSManagedObject subclass.
    
    private static func fetchRequest(predicate: NSPredicate? = nil,
                             sortedBy: AttributeName? = nil,
                             ascending: Bool = true,
                             fetchLimit: Int = 0) -> NSFetchRequest<FetchableType>
    {
        let sortDescriptors : [NSSortDescriptor]? = sortedBy != nil ? [NSSortDescriptor(key: sortedBy!.rawValue, ascending: ascending)] : nil
        return fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
    }  
    
    
    /// A Core Data fetch request for the current NSManagedObject subclass for sorting by an array of sort descriptors.
    ///
    /// - Parameters:
    ///   - predicate: The fetch predicate (optional, default is nil).
    ///   - sortDescriptors: An array of sort descriptors (optional, default is not sorted).
    ///   - fetchLimit: The number of items to be fetched (optional, default is no limit).
    /// - Returns: The fetch request for the current NSManagedObject subclass.
    
    private static func fetchRequest(predicate: NSPredicate? = nil,
                             sortDescriptors: [NSSortDescriptor]?,
                             fetchLimit: Int = 0) -> NSFetchRequest<FetchableType>
    {
        let request = NSFetchRequest<FetchableType>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = fetchLimit
        return request
    }
    
    
    /// Insert a new object in the current entity.
    ///
    /// - Returns: The created NSManagedObject instance.
    
    static func insertNewObject() -> FetchableType
    {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext) as! FetchableType
    }
    
    
    /// Delete all objects of the current entity.
    
    static func deleteAll() throws
    {
        let request = NSFetchRequest<FetchableType>(entityName: entityName)
        if #available(iOS 9, macOS 10.11, *) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
            let persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator!
            try persistentStoreCoordinator.execute(deleteRequest, with: managedObjectContext)
        } else {
            let fetchResults = try managedObjectContext.fetch(request)
            for anItem in fetchResults {
                managedObjectContext.delete(anItem)
            }
        }
    }
}
