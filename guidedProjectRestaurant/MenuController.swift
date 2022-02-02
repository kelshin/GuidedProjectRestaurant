//
//  MenuController.swift
//  guidedProjectRestaurant
//
//  Created by Kelbin David on 2022-01-30.
//

import Foundation
import UIKit

class MenuController {
    static let shared = MenuController()
    var order = Order() {
        didSet{
            NotificationCenter.default.post(name: MenuController.orderUpdateNotification, object: nil)
        }
    }
    let baseURL = URL(string: "http://localhost:8080/")!
    static let orderUpdateNotification = Notification.Name("MenuController.orderUpdated")
    
    func fetchCategories(completion: @escaping (Result<[String], Error>) -> Void) {
        let catergoriesURL = baseURL.appendingPathComponent("categories")
        let task = URLSession.shared.dataTask(with: catergoriesURL) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let categoriesResponse = try jsonDecoder.decode(CategoriesResponse.self, from: data)
                    completion(.success(categoriesResponse.categories))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchMenuItems(forCategory categoryName: String, completion: @escaping (Result<[MenuItem], Error>) -> Void){
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = components.url!
        let task = URLSession.shared.dataTask(with: menuURL) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let menuResponse = try jsonDecoder.decode(MenuResponse.self, from: data)
                    completion(.success(menuResponse.items))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    typealias MinuteToPrepare = Int
    
    func submitOrder(forMenuIDs menuIDs: [Int], completion: @escaping (Result<MinuteToPrepare, Error>) -> Void){
        let orderURL = baseURL.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
                    completion(.success(orderResponse.prepTime))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void){
        let task = URLSession.shared.dataTask(with: url){
            (data, response, error) in
            if let data = data,
               let image = UIImage(data: data){
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
