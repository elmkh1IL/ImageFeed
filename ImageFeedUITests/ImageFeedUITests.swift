import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launchArguments.append("UITEST")
        app.launch() // запускаем приложение перед каждым тестом
        print(app.launchArguments)
    }
    
    private func login() {
        if app.tables.firstMatch.waitForExistence(timeout: 3) {
            return
        }
        
        let authenticateButton = app.buttons["authenticateButton"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10))
        authenticateButton.tap()
        
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 20))
        print(app.debugDescription)
        
        sleep(2)
        
        // Поле логина
        let loginField = webView.textFields.firstMatch
        XCTAssertTrue(loginField.waitForExistence(timeout: 20))
        
        loginField.tap()
        loginField.typeText("el.mkh@inbox.ru")
        
        let passwordField = webView.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 20))
        
        passwordField.tap()
        passwordField.typeText("11zz98dfgAf")
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
        
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 30))
        
        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 20))
    }
    
    // тестируем сценарий авторизации
    func testAuth() throws {
        // Нажать кнопку авторизации
        print(app.debugDescription)
        let authenticateButton = app.buttons["authenticateButton"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10), "Кнопка authenticateButton не найдена")
        authenticateButton.tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        sleep(5)
        print(app.debugDescription)
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("") //TODO: УДАЛИТЬ СВОИ ДАННЫЕ
        
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        passwordTextField.typeText("") //TODO: УДАЛИТЬ СВОИ ДАННЫЕ
        
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        print(app.debugDescription)
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        tablesQuery.children(matching: .cell).element(boundBy: 0)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    // тестируем сценарий ленты
    func testFeed() throws {
        login()
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 15))
        
        // Ждем появления первой ячейки
        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        // Скроллим один экран
        table.swipeUp()
        
        // Берем вторую ячейку
        let cell = table.cells.element(boundBy: 1)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        
        // Если ячейка не видна — прокручиваем до нее
        if !cell.isHittable {
            table.swipeUp()
        }
        
        XCTAssertTrue(cell.isHittable)
        
        // Ищем кнопку лайка именно внутри этой ячейки
        let likeButton = cell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(likeButton.isHittable)
        
        likeButton.tap()
        sleep(1)
        
        likeButton.tap()
        sleep(1)
        
        // Открываем фотографию
        cell.tap()
        
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        
        image.pinch(withScale: 3.0, velocity: 1.0)
        image.pinch(withScale: 0.5, velocity: -1.0)
        
        let backButton = app.buttons["navBackButtonWhite"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        
    }
    
    // тестируем сценарий профиля
    func testProfile() throws {
        print(app.debugDescription)
        sleep(5)
        print(app.debugDescription)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 10))
        
        XCTAssertTrue(app.staticTexts["profileNameLabel"].exists)
        XCTAssertTrue(app.staticTexts["profileUsernameLabel"].exists)
        logoutButton.tap()
        
        let confirmButton = app.buttons.matching(identifier: "logoutAlertConfirm").firstMatch
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()
    }
}
