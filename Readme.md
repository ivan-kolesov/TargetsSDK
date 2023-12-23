Минимальные требования для работы библиотеки версия iOS >= 14

# Подключение TargetsSDK к своему проекту

Библиотеку можно подключить двумя способами: SPM, Framework архив

<!---
## SPM
1. В `File -> Add Packages` укажите `https://github.com/ivan-kolesov/TargetsSDK`
2. Выберите `Up to next major version`
3. Добавьте пакет.
-->

## Framework архив
1. Скачайте архив
2. Разархивируйте архив
3. Подключите к проекту зависимость в `General -> Framework, Libraries, and Embedded Content` библиотеку из каталога `TargetsSDK.xcframework` (убедитесь, что поставили чекбокс `Copy if Needed`)

# Инициализация библиотеки
1. Создайте SceneDelegate.swift со следующим содержимым:
```
import UIKit
import TargetsSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        SDKMetrica.shared.scene(scene, willConnectTo: session, options: connectionOptions)
    }
}
```

2. Создайте AppDelegate.swift со следующим содержимым:
```
import TargetsSDK
import UIKit

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

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SDKMetrica.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        SDKMetrica.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        SDKMetrica.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}
```
При создании экземпляра config, передается API_KEY, который необходимо получить при регистрации приложения в [личном кабинете](https://st.targets.plus/#/) (ЛК).

Вызов метода `enableLocationTracking` является опциональным, его отсутствие вызова или вызов с параметром `isEnabled = false` - выключает фоновый трекинг геолокации пользователя.

> Если в проекте используется исключительно SwiftUI можно добавить AppDelegate, используя следующее подключение в AppView:

```
@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
```

3. Добавьте в Info.plist ключи:

| Ключ                                                        | Тип     |Значение|
|-------------------------------------------------------------|---------|------------------------------------|
| FirebaseAppDelegateProxyEnabled                             | Boolean | NO                                 |
| Privacy - Contacts Usage Description                        | String  |Необходимость использования контакнтых данных|
| Required background modes                                   | Array   |                                     |
| item 0                                                      | String  |App downloads content from the network|
| item 1                                                      | String  |App downloads content in response to push notifications|

4. Добавьте в entitlements файл записи:

|Ключ|Тип|Значение|
|---|---|---|
|com.apple.developer.networking.wifi-info|Boolean|YES|
|APS Environment|String|production|

5. Добавьте конфигурационный файл Firebase `GooleService-Info.plist`.
> Как сформировать этот файл можно ознакомиться на сайте [https://firebase.google.com/docs/ios/setup](https://firebase.google.com/docs/ios/setup)

6. Если в приложении не используется геолокация, но есть необходимость получать в событиях геоданные, для этого можно подключить как пример следующий сервис:

```
import Foundation
import CoreLocation
    
class AppLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        lastLocation = location
    }
}
```
и подключить его, например так в SwiftUI:
```
@StateObject private var locationManager = AppLocationManager()
```

Добавьте в Info.plist ключи:

| Ключ                                                        | Тип     |Значение|
|-------------------------------------------------------------|---------|------------------------------------|
| Privacy - Location Always Usage Description                        | String  |Необходимость использования локации|
| Privacy - Location When In Use Usage Description                        | String  |Необходимость использования локации|
| Privacy - Location Always and When In Use Usage Description                        | String  |Необходимость использования локации|

# Отправка данных с помощью репортера

Отправлять данные возможно на любые триггерные события в приложении:
```
SDKMetrica.shared.reportEvent(name: String)
```
Отправка события со значением:
```
SDKMetrica.shared.reportEvent(name: String, value: String)
```

Аккумулированные данные по событиям доступны в [ЛК](https://st.targets.plus/#/stats)

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

В проекте у NotificationService `Build -> Frameworks and Libraries` добавьте `TargetsSDK` с типом `Do not embed`. 
Убедитесь, что `Deployment Target` у сервиса расширения меньше, чем версия iOS на телефоне. 

# Подключение Notification Content Service

В `File -> New -> Target` выберете `Notification Content Extension` и укажите `Product Name` как `NotificationContent`.
На вопрос `Activate “NotificationContentService” scheme` выберете `Cancel`.

В созданном файле NotificationViewController.swift замените содержимое на следующий код

```
import UIKit
import TargetsSDK
    
class NotificationViewController: SDKMetricaContentExtension {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
}
```

В Info.plist сделайте следующие изменения:
* для параметра `UNNotificationExtensionCategory` укажите `video`;
* имя параметра `NSExtensionMainStoryboard` замените на `NSExtensionPrincipalClass` и укажите значение параметра `NotificationContent.NotificationViewController`.

В проекте `NotificationContent` в настройке `Build -> Frameworks and Libraries` добавьте `TargetsSDK` с типом `Do not embed`.

Убедитесь, что `Deployment Target` у сервиса расширения меньше, чем версия iOS на телефоне. 
