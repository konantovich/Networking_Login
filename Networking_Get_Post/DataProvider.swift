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
    
    //создаем URLSession с конфигом (настройками)
    private lazy var bgSession: URLSession = {//параметры конфига для фоновой загрузки данных
        let config = URLSessionConfiguration.background(withIdentifier: "ru.swiftbook.networking")//определяет поведение при загрузке и выгрузке данных, .background создание параметров конфига(с возможностью фоновой загрузки данных)
        config.isDiscretionary = true //определяет могут ли фоновые задачи быть запланированы на усмотрение системы (оптимизация планирования)
        config.timeoutIntervalForResource = 300 //Время ожидание сети в секундах
        config.waitsForConnectivity = true //Ожидание подключение к сети (по умолчанию true)
        config.sessionSendsLaunchEvents = true//по завершению загрузки данных наше приложение запустится в фоновом режиме
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)//возвращаем URLSession с нашим конфигом
    }()
    
    //тут будет задача по загрузке данных
    func startDownload () {
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin"){
            downloadTask = bgSession.downloadTask(with: url)//открываем URLSession c нашим конфигом(после инициализации сессии мы не сможем вносить никакие параметры в конфиг)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)//загрузка начнется не ранее заданого времени
            downloadTask.countOfBytesClientExpectsToSend = 512 //определяет найболее вероятную верхнюю границу числа байтов (которую клиент отпраляет)
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024//верхняя граница(граница контроольной суммы)) числа байтов (которую клиент ожидает получить)
            downloadTask.resume() //запускаем
        }
    }
    
    //тут сможем остановить загрузку данных
    func stopDownload () {
        downloadTask.cancel() //останавливаем
    }
}

extension DataProvider: URLSessionDelegate {
    
    //будет вызываться по завершению всех фоновых задач помещенных в очередь с нашим withIdentifier приложения. И отправлять их в APPDelegate/handleEventsForBackgroundURLSession
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //теперь когда у нас есть метод для сопоставление делегатов сессий, мы можем вызвать его передав в блок идентификатор нашей сессии
        DispatchQueue.main.async {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.bgSessionCompletionHandler
                else {return}
            
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()//создаем константу completionHandler в которую передаем захваченое значение идентификатора нашей сессии из свойства bgSessionCompletionHandler класса AppDelegate, затем мы обнуляем значение этого свойства (присваивая nil) и вызываем исходный блок completionHandler() что бы уведомить систему что загрузка была завершена.
        }
        
    }
}


extension DataProvider: URLSessionDownloadDelegate {
    //получить ссылку на загруженый файл, а также отобразить загрузку данных
    //содержит ссылку на временную директорию куда закачивается файл
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Did finish downloading: \(location.absoluteString)")
        
        //по сколько загруженный файл временный, по этому нужно либо открыть файл либо его переместить в место для постоянного хранения
        //если открываем файл, то нужно выполнить в другом потоке чтобы избежать ошибки очереди делегатов
        DispatchQueue.main.async {
            self.fileLocation?(location) //сохранение ссылки на временную директорию
        }
        
    }
    
    //Метод делегата для оботражения загрузки
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {return} //если ожидаемый размер файла меньше то выходим
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) //присваиваем результат деления количество переданых байт на общее количество байт
        print("Download progress: \(progress)")
        
        //присвоим полученное значение переменной onProgress
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
    
    
}
