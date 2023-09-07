Минимальные требования для работы библиотеки версия iOS >= 14

# Подключение TargetsSDK к своему проекту

Библиотеку можно подключить тремя способами: SPM, Cocoapod, Framework архив

## SPM
1. В `File -> Add Packages` укажите `https://github.com/ivan-kolesov/TargetsSDK`
2. Выберите `Up to next major version`
3. Добавьте пакет.

## Cocoapod
.........

## Framework архив
1. Скачайте архив
2. Разархивируйте архив
3. Подключите к проекту зависимость в `General -> Framework, Libraries, and Embedded Content` библиотеку из каталога `TargetsSDK.xcframework` (убедитесь, что поставили чекбокс `Copy if Needed`)

# Инициализация библиотеки
1. Создайте AppDelegate.swift со следующим содержимым:
```
    import TargetsSDK
    import SwiftUI

    class AppDelegate: UIResponder, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    
            Task {
                let config = await SDKMetricaConfig.builder(apiKey: "API_KEY")
                    .enableLocationTracking(isEnabled: true)
                    .build()
                SDKMetrica.shared.activate(config: config)
            }
            
            return true
        }
        
        public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            return SDKMetrica.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    
        public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            return SDKMetrica.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    
        public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                             fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            return SDKMetrica.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }
    }
```
При создании экземпляра config, передается API_KEY, который необходимо получить при регистрации приложения в [личном кабинете](ссылка на сайт ЛК) (ЛК).

Вызов метода `enableLocationTracking` является опциональным, его отсутствие вызова или вызов с параметром `isEnabled = false` - выключает фоновый трекинг геолокации пользователя.


2. Добавьте в Info.plist ключи:

| Ключ                                                        | Тип     |Значение|
|-------------------------------------------------------------|---------|------------------------------------|
| FirebaseAppDelegateProxyEnabled                             | Boolean | NO                                 |
| Privacy - Location Always and When In Use Usage Description | String  | Description of required permissions |
| Privacy - Location When In Use Usage Description            | String  |Description of required permissions|
| Privacy - Contacts Usage Description                        | String  |Usage contact list description|
| Required background modes                                   | Array   |                                     |
| item 0                                                      | String  |App downloads content from the network|
| item 1                                                      | String  |App downloads content in response to push notifications|

3. Добавьте в entitlements файл записи:

|Ключ|Тип|Значение|
|---|---|---|
|com.apple.developer.networking.wifi-info|Boolean|YES|
|APS Environment|String|production|

4. Добавьте конфигурационный файл Firebase `GooleService-Info.plist`

# Отправка данных с помощью репортера

Отправлять данные возможно на любые триггерные события в приложении:
```
    SDKMetrica.shared.reportEvent(name: String)
```
Отправка события со значением:
```
    SDKMetrica.shared.reportEvent(name: String, value: String)
```

# Подключение Notification Service

В `File -> New -> Target` выберете `Notification Service Extension` и укажите `Product Name` как `NotificationService`.
На вопрос `Activate “NotificationService” scheme` выберете `Activate`.

В созданном файле NotificationService.swift замените содержимое на следующий код

```
    import UserNotifications
    import TargetsSDK
    
    class NotificationService: SDKMetricaServiceExtension {
        override func didReceive(
            _ request: UNNotificationRequest,
            withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
        ) {
            super.didReceive(request, withContentHandler: contentHandler)
        }
    }
```
