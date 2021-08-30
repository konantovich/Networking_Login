//
//  DataProvider.swift
//  Networking_Get_Post
//
//  Created by Antbook on 05.08.2021.
//

import UIKit


class DataProvider: NSObject {

    private var downloadTask: URLSessionDownloadTask! //будем передавать в это свойство параметры конфига и использовать этот объект для настройки сессии
    var fileLocation: ((URL)->())? //сюда передаем ссылку на наш временный файл
    var onProgress: ((Double)->())? //отображение прогреса загрузки файла
    
  
    private lazy var bgSession: URLSession = {//параметры конфига для фоновой загрузки данных
        let config = URLSessionConfiguration.background(withIdentifier: "ru.swiftbook.networking")
        config.isDiscretionary = true
        config.timeoutIntervalForResource = 300 //Время ожидание сети в секундах
        config.waitsForConnectivity = true //Ожидание подключение к сети (по умолчанию true)
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    //задача по загрузке данных
    func startDownload () {
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin"){
            downloadTask = bgSession.downloadTask(with: url)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            downloadTask.countOfBytesClientExpectsToSend = 512
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024//верхняя граница(граница контроольной суммы)) числа байтов (которую клиент ожидает получить)
            downloadTask.resume()
        }
    }
    
    //тут можем остановить загрузку данных
    func stopDownload () {
        downloadTask.cancel()
    }
}

extension DataProvider: URLSessionDelegate {
    
    //отправляем в Appdelegate
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        DispatchQueue.main.async {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.bgSessionCompletionHandler
                else {return}
            
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()
        }
        
    }
}


extension DataProvider: URLSessionDownloadDelegate {
    //получить ссылку на загруженый файл, а также отобразить загрузку данных
    //содержит ссылку на временную директорию куда закачивается файл
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Did finish downloading: \(location.absoluteString)")
      
        DispatchQueue.main.async {
            self.fileLocation?(location) //сохранение ссылки на временную директорию
        }
        
    }
    
    //оботражения загрузки
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {return} //если ожидаемый размер файла меньше то выходим
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("Download progress: \(progress)")
       
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
    
    
}
