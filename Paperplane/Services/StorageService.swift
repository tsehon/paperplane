//
//  StorageService.swift
//  Paperplane
//
//  Created by tyler on 2/28/24.
//

import Foundation
import AWSClientRuntime
import AWSS3

class StorageService: ObservableObject {
    static let shared = StorageService() // Singleton instance
    
    private var client: S3Client?
    
    private init() {
        do {
            self.client = try S3Client(region: "us-west-1")
        } catch {
            dump(error, name: "Error accessing S3 service")
        }
    }
    
        
    func fetchPreSignedURL(key id: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "https://paperplane-library.s3.us-west-1.amazonaws.com/environments/underwater_og.mov?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEAwaCXVzLXdlc3QtMSJIMEYCIQC5Urfyu9xG3154K5M3t0FbwcmbPrcaYLGTbdugJG%2FsJQIhALH%2Bi2gHWfx4wTtNzOZpFcj7%2FR4XEOhFheMbFkiUWjlYKu0CCPX%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQABoMNTMzMjY3MzM5Njk5Igzo%2BA3kwlK%2FIW5TwXUqwQLN2V9fmk%2FM05iHFisc%2F3TbYELsAwY8C7H23Ued7HpJAv%2FefMM50dKtBchAUIkjACdHCgG%2FcpSd98xtQ4%2Fx7AYSsBsoaDbmu8wqn3vAue8rUap%2FqxJdZn%2B7pr%2BoQzlzotmkY%2B9AQqjKikHx5l3Uew4IR74vrxqMIMERZCFHbOhfJ335utdGTstqEu9GqElM6x3O%2BCITo2n9AUxFr1nXei25baT4rRH035yZ8aRAaxRCjoKhHCLZ6svtB9Et7jGBgvEpHyze2%2BIHaFrb5nliOMzjWUelPn%2FcLL23pTonDGOhYFOcGvtzeaUbJtB7xiTo1u0ndz%2FyELMXUBXLtwaXkjQcpCGb7kOjHmPgYT1f93hPvw0VcEAESrhj%2BxMzPla5S4mB3jlse2GS88%2B4mPtOMzIqFvmRIM%2BcRzgmzdYtft2LguowmKT%2BrgY6sgKXSOffkq1Hi0%2Fyxi%2BWpb%2BRm1ItG8NVCBpWVQLOMsVvOvAy3Vx4GBcR8dhHT5XmmnM0LrIqhXKfupcV7Q8YLcU%2FgmmUDibzTbuoakDTvLaAduGx11V0vwGMrAh1d3UyY2Ch5momiKSvHX6LIfbxrY%2BifFELsw%2BAtf6qHM50wLQpI50n86dpfJocG4RDW5iDe7w%2FCoegiV0fgKpXcVxhIeL5hmnQrqiktaycWnq%2BKEZfnwsDPhDxdbuiZB%2B372Mbum590EDg72jkecgttH8lDX2eGwM0vBQvLunsVyVP5Ag1s%2BNN%2BllEBnMw%2FQHRnGJ5RxR5nAMwaEHyedAeypdk6IlRL%2BZE7%2BzJZgDJrix%2FVHjKR%2BGHxByE3ioNrCfaVH36SywBIF58JqhA71zz8EaM3vsn3lE%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20240228T232754Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAXYKJV3GZY3UZO2B7%2F20240228%2Fus-west-1%2Fs3%2Faws4_request&X-Amz-Signature=9697a696e4e1e67edf20479bb0d00f75ec0f851d70f5c1805d2bf69fad11e65d") else {
            completion(nil)
            return
        }
        completion(url)
        /*
        let urlString = "http://localhost:8080/environment/\(id)"
        guard let url = URL(string: urlString) else {
            print("\(#file) \(#function): Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching signed URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let signedURLString = json["url"] as? String,
                   let signedURL = URL(string: signedURLString) {
                    completion(signedURL)
                } else {
                    print("Could not parse JSON response")
                    completion(nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
         */
    }
}
