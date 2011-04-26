//
//  TICDSFileManagerBasedSynchronizationOperation.m
//  ShoppingListMac
//
//  Created by Tim Isted on 26/04/2011.
//  Copyright 2011 Tim Isted. All rights reserved.
//

#import "TICoreDataSync.h"


@implementation TICDSFileManagerBasedSynchronizationOperation

- (void)buildArrayOfClientDeviceIdentifiers
{
    NSError *anyError = nil;
    NSArray *directoryContents = [[self fileManager] contentsOfDirectoryAtPath:[self thisDocumentSyncChangesDirectoryPath] error:&anyError];
    
    if( !directoryContents ) {
        [self setError:[TICDSError errorWithCode:TICDSErrorCodeFileManagerError underlyingError:anyError classAndMethod:__PRETTY_FUNCTION__]];
        [self builtArrayOfClientDeviceIdentifiers:nil];
        return;
    }
    
    NSMutableArray *clientDeviceIdentifiers = [NSMutableArray arrayWithCapacity:[directoryContents count]];
    for( NSString *eachDirectory in directoryContents ) {
        if( [[eachDirectory substringToIndex:1] isEqualToString:@"."] ) {
            continue;
        }
        
        [clientDeviceIdentifiers addObject:eachDirectory];
    }
    
    [self builtArrayOfClientDeviceIdentifiers:clientDeviceIdentifiers];
}

- (void)uploadLocalSyncChangeSetFileAtLocation:(NSURL *)aLocation
{
    NSError *anyError = nil;
    
    NSString *uploadPath = [[self thisDocumentSyncChangesThisClientDirectoryPath] stringByAppendingPathComponent:[[aLocation path] lastPathComponent]];
    
    BOOL success = [[self fileManager] moveItemAtPath:[aLocation path] toPath:uploadPath error:&anyError];
    
    if( !success ) {
        [self setError:[TICDSError errorWithCode:TICDSErrorCodeFileManagerError underlyingError:anyError classAndMethod:__PRETTY_FUNCTION__]];
    }
    
    [self uploadedLocalSyncChangeSetFileSuccessfully:success];
}

- (void)buildArrayOfSyncChangeSetIdentifiersForClientIdentifier:(NSString *)anIdentifier
{
    NSError *anyError = nil;
    NSArray *contents = [[self fileManager] contentsOfDirectoryAtPath:[self pathToSyncChangesDirectoryForClientWithIdentifier:anIdentifier] error:&anyError];
    
    if( !contents ) {
        [self setError:[TICDSError errorWithCode:TICDSErrorCodeFileManagerError underlyingError:anyError classAndMethod:__PRETTY_FUNCTION__]];
    }
    
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:[contents count]];
    for( NSString *eachIdentifier in contents ) {
        if( [[eachIdentifier substringToIndex:1] isEqualToString:@"."] ) {
            continue;
        }
        
        [identifiers addObject:eachIdentifier];
    }
    
    [self builtArrayOfClientSyncChangeSetIdentifiers:identifiers forClientIdentifier:anIdentifier];
}

#pragma mark -
#pragma mark Initialization and Deallocation
- (void)dealloc
{
    [_thisDocumentSyncChangesDirectoryPath release], _thisDocumentSyncChangesDirectoryPath = nil;
    [_thisDocumentSyncChangesThisClientDirectoryPath release], _thisDocumentSyncChangesThisClientDirectoryPath = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark Paths
- (NSString *)pathToSyncChangesDirectoryForClientWithIdentifier:(NSString *)anIdentifier
{
    return [[self thisDocumentSyncChangesDirectoryPath] stringByAppendingPathComponent:anIdentifier];
}

#pragma mark -
#pragma mark Properties
@synthesize thisDocumentSyncChangesDirectoryPath = _thisDocumentSyncChangesDirectoryPath;
@synthesize thisDocumentSyncChangesThisClientDirectoryPath = _thisDocumentSyncChangesThisClientDirectoryPath;

@end