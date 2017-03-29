import AWSSignatureV4
import Vapor
import S3

private let s3StorageKey = "s3-provider:s3"

public final class Provider: Vapor.Provider {
    let s3: S3

    /// Initialize the provider with an s3 instance
    public init(_ s3: S3) {
        self.s3 = s3
    }

    /// Create an s3 instance with host, accessKey, secretKey, and region
    public convenience init(bucket: String, accessKey: String, secretKey: String, region: Region) {
        let s3 = S3(bucket: bucket, accessKey: accessKey, secretKey: secretKey, region: region)
        self.init(s3)
    }

    /// Initialize the s3 instance from configboo
    /// expects `s3.json` with following keys:
    /// host: String
    /// accessKey: String
    /// secretKey: String
    /// region: String -- matching official AWS Region list
    public convenience init(config: Config) throws {
        guard let s3Config = config["s3"] else { throw VaporS3Error.missingFile("s3") }
        guard let bucket = s3Config["bucket"]?.string else {
            throw VaporS3Error.configMissing("bucket")
        }
        guard let accessKey = s3Config["accessKey"]?.string else {
            throw VaporS3Error.configMissing("accessKey")
        }
        guard let secretKey = s3Config["secretKey"]?.string else {
            throw VaporS3Error.configMissing("secretKey")
        }
        guard let region = s3Config["region"]?.string.flatMap(Region.init) else {
            throw VaporS3Error.configMissing("region")
        }
        self.init(bucket: bucket, accessKey: accessKey, secretKey: secretKey, region: region)
    }

    
    
    public func boot(_ drop: Droplet) {
        //
    }
    
    public func afterInit(_ drop: Droplet) {
        drop.storage[s3StorageKey] = s3
    }

    public func beforeRun(_ drop: Droplet) {
        print("Amazon S3 has been set up for host:\n\(s3.host)\n")
    }
    
}

extension Droplet {
    /// Use this function to access the underlying
    /// s3 object.
    ///
    /// make sure that VaporS3 has been added properly
    /// before doing
    public func s3() throws -> S3 {
        guard let s3 = storage[s3StorageKey] as? S3 else { throw VaporS3Error.s3NotConfigured }
        return s3
    }
}
