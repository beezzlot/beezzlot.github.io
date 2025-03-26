Чтобы реализовать переход пользователя в личный кабинет после регистрации, мы внесем изменения в приложение. Помимо этого, добавим пользователя admin с заранее заданным ID 247 в базу данных. Вот что нужно изменить:

---

### Измененный код приложения (app.py)

from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Модель пользователя
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Уникальный ID пользователя
    username = db.Column(db.String(150), nullable=False, unique=True)  # Имя пользователя
    email = db.Column(db.String(150), nullable=False, unique=True)  # Почта
    password = db.Column(db.String(150), nullable=False)  # Пароль

# Создание главной страницы
@app.route('/')
def index():
    return render_template('index.html')

# Регистрация пользователя
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        
        # Создание нового пользователя
        new_user = User(username=username, email=email, password=password)
        try:
            db.session.add(new_user)
            db.session.commit()
            # Перенаправление в личный кабинет после регистрации
            return redirect(url_for('dashboard', user_id=new_user.id))
        except:
            return "Ошибка: Этот пользователь уже существует."

    return render_template('register.html')

# Личный кабинет пользователя
@app.route('/id/<int:user_id>')
def dashboard(user_id):
    # Извлечение информации о пользователе по ID
    user = User.query.get_or_404(user_id)
    return render_template('dashboard.html', user=user)

# Добавление пользователя admin с ID 247, если его еще нет
@app.before_first_request
def create_admin():
    db.create_all()  # Создание таблиц в базе данных
    admin = User.query.get(247)
    if not admin:
        admin = User(id=247, username='admin', email='admin@example.com', password='admin123')
        db.session.add(admin)
        db.session.commit()

if __name__ == '__main__':
    app.run(debug=True)


---

### Измененные шаблоны

index.html

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Главная</title>
</head>
<body>
    <header>
        <h1>Добро пожаловать!</h1>
    </header>
    <main>
        <a href="{{ url_for('register') }}">Регистрация</a>
        <p>Пользователь admin уже существует. Его ID: <strong>247</strong></p>
        <a href="{{ url_for('dashboard', user_id=247) }}">Войти в личный кабинет admin</a>
    </main>
</body>
</html>


---

register.html

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Регистрация</title>
</head>
<body>
    <header>
        <h1>Регистрация</h1>
    </header>
    <main>
        <form method="POST">
            <label for="username">Имя пользователя:</label>
            <input type="text" id="username" name="username" required>
            
            <label for="email">Эл. почта:</label>
            <input type="email" id="email" name="email" required>
            
            <label for="password">Пароль:</label>
            <input type="password" id="password" name="password" required>

            <button type="submit">Зарегистрироваться</button>
        </form>
    </main>
</body>
</html>


---

dashboard.html (новый файл для личного кабинета)

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Личный кабинет</title>
</head>
<body>
    <header>
        <h1>Личный кабинет</h1>
    </header>
    <main>
