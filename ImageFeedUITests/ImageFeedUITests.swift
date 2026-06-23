import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    // тестируем сценарий авторизации
    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("") //TODO: УДАЛИТЬ СВОИ ДАННЫЕ
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("") //TODO: УДАЛИТЬ СВОИ ДАННЫЕ
        webView.swipeUp()
        print(app.debugDescription)
        
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        tablesQuery.children(matching: .cell).element(boundBy: 0)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        print(app.debugDescription)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    // тестируем сценарий ленты
    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["like button on"].tap()
        
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["like button off"].tap()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
        
    }
    
    // тестируем сценарий профиля
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        app.buttons["logout button"].tap()
        
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
