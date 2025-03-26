from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = 'your-secret-key-here'  # Обязательно замените на реальный секретный ключ!

db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), nullable=False, unique=True)
    email = db.Column(db.String(150), nullable=False, unique=True)
    password = db.Column(db.String(150), nullable=False)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        
        # Проверка существующего пользователя
        if User.query.filter_by(username=username).first():
            flash('Это имя пользователя уже занято')
            return redirect(url_for('register'))
        if User.query.filter_by(email=email).first():
            flash('Этот email уже используется')
            return redirect(url_for('register'))
        
        # Хеширование пароля (правильный способ)
        hashed_password = generate_password_hash(password)
        
        new_user = User(
            username=username,
            email=email,
            password=hashed_password
        )
        
        try:
            db.session.add(new_user)
            db.session.commit()
            return redirect(url_for('dashboard', user_id=new_user.id))
        except Exception as e:
            db.session.rollback()
            flash(f'Ошибка регистрации: {str(e)}')
            return redirect(url_for('register'))

    return render_template('register.html')

@app.route('/id/<int:user_id>')
def dashboard(user_id):
    user = User.query.get_or_404(user_id)
    return render_template('dashboard.html', user=user)

def setup_database():
    with app.app_context():
        db.create_all()
        # Создаём администратора, если его нет
        if not User.query.get(247):
            admin = User(
                id=247,
                username='admin',
                email='admin@example.com',
                password=generate_password_hash('admin123')
            )
            db.session.add(admin)
            db.session.commit()

if __name__ == '__main__':
    setup_database()
    app.run(host='0.0.0.0', port=5000, debug=True)




# BASE.HTML
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Minerals Ural Mining | {% block title %}{% endblock %}</title>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2c3e50;
            --secondary: #e67e22;
            --dark: #1a252f;
            --light: #ecf0f1;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Montserrat', sans-serif;
        }
        
        body {
            background: url('https://images.unsplash.com/photo-1519681393784-d120267933ba') no-repeat center/cover;
            color: var(--light);
            min-height: 100vh;
            position: relative;
        }
        
        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: -1;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 0;
            border-bottom: 1px solid var(--secondary);
        }
        
        .logo {
            font-size: 2rem;
            font-weight: 700;
            color: var(--secondary);
            text-transform: uppercase;
        }
        
        nav a {
            color: var(--light);
            text-decoration: none;
            margin-left: 20px;
            transition: 0.3s;
        }
        
        nav a:hover {
            color: var(--secondary);
        }
        
        .btn {
            display: inline-block;
            background: var(--secondary);
            color: var(--dark);
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 700;
            transition: 0.3s;
        }
        
        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        footer {
            text-align: center;
            padding: 20px;
            margin-top: 50px;
            border-top: 1px solid var(--secondary);
        }
        
        /* Анимации */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .fade-in {
            animation: fadeIn 1s ease-in;
        }
    </style>
    {% block styles %}{% endblock %}
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">GoldPeak</div>
            <nav>
                <a href="/">Главная</a>
                <a href="/register">Регистрация</a>
            </nav>
        </header>
        
        <main class="fade-in">
            {% block content %}{% endblock %}
        </main>
        
        <footer>
            <p>© 2025 Minerals Ural Mining Company. Все права защищены.</p>
        </footer>
    </div>
    
    {% block scripts %}{% endblock %}
</body>
</html>



# BASE
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Minerals Ural Mining | {% block title %}{% endblock %}</title>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2c3e50;
            --secondary: #e67e22;
            --dark: #1a252f;
            --light: #ecf0f1;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Montserrat', sans-serif;
        }
        
        body {
            background: url('/file.img') no-repeat center/cover;
            color: var(--light);
            min-height: 100vh;
            position: relative;
        }
        
        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: -1;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 0;
            border-bottom: 1px solid var(--secondary);
        }
        
        .logo {
            font-size: 2rem;
            font-weight: 700;
            color: var(--secondary);
            text-transform: uppercase;
        }
        
        nav a {
            color: var(--light);
            text-decoration: none;
            margin-left: 20px;
            transition: 0.3s;
        }
        
        nav a:hover {
            color: var(--secondary);
        }
        
        .btn {
            display: inline-block;
            background: var(--secondary);
            color: var(--dark);
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 700;
            transition: 0.3s;
        }
        
        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        footer {
            text-align: center;
            padding: 20px;
            margin-top: 50px;
            border-top: 1px solid var(--secondary);
        }
        
        /* Анимации */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .fade-in {
            animation: fadeIn 1s ease-in;
        }
    </style>
    {% block styles %}{% endblock %}
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">GoldPeak</div>
            <nav>
                <a href="/">Главная</a>
                <a href="/register">Регистрация</a>
            </nav>
        </header>
        
        <main class="fade-in">
            {% block content %}{% endblock %}
        </main>
        
        <footer>
            <p>© 2025 Minerals Ural Mining Company. Все права защищены.</p>
        </footer>
    </div>
    
    {% block scripts %}{% endblock %}
</body>
</html>

# INDEX
{% extends "base.html" %}

{% block title %}Добыча золота премиум-класса{% endblock %}

{% block content %}
<section class="hero">
    <div style="text-align: center; padding: 100px 0;">
        <h1 style="font-size: 3rem; margin-bottom: 20px;">ЗОЛОТО ВЫСШЕЙ ПРОБЫ</h1>
        <p style="font-size: 1.2rem; max-width: 800px; margin: 0 auto 30px;">
            Компания Minerals Ural - лидер в добыче драгоценных металлов с 1998 года. 
            Наши месторождения расположены в экологически чистых районах Урала.
        </p>
        <a href="/register" class="btn" style="font-size: 1.1rem;">Присоединиться</a>
    </div>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-top: 50px;">
        <div class="card" style="background: rgba(255, 255, 255, 0.1); padding: 20px; border-radius: 10px;">
            <h3 style="color: var(--secondary); margin-bottom: 15px;">Наши технологии</h3>
            <p>Используем инновационные методы добычи без вреда для природы</p>
        </div>
        
        <div class="card" style="background: rgba(255, 255, 255, 0.1); padding: 20px; border-radius: 10px;">
            <h3 style="color: var(--secondary); margin-bottom: 15px;">Качество</h3>
            <p>99.9% чистоты золота в каждой партии</p>
        </div>
        
        <div class="card" style="background: rgba(255, 255, 255, 0.1); padding: 20px; border-radius: 10px;">
            <h3 style="color: var(--secondary); margin-bottom: 15px;">Экспертиза</h3>
            <p>Команда из 200+ профессиональных геологов</p>
        </div>
    </div>
</section>
{% endblock %}

# REGISTER
{% extends "base.html" %}

{% block title %}Регистрация | GoldPeak{% endblock %}

{% block content %}
<div style="max-width: 500px; margin: 50px auto; background: rgba(255, 255, 255, 0.1); padding: 30px; border-radius: 10px;">
    <h2 style="text-align: center; margin-bottom: 30px; color: var(--secondary);">Регистрация</h2>
    
    {% with messages = get_flashed_messages() %}
        {% if messages %}
            <div style="color: #e74c3c; margin-bottom: 20px;">
                {% for message in messages %}
                    <p>{{ message }}</p>
                {% endfor %}
            </div>
        {% endif %}
    {% endwith %}
    
    <form method="POST" style="display: grid; gap: 20px;">
        <div>
            <label style="display: block; margin-bottom: 5px;">Имя пользователя</label>
            <input type="text" name="username" required style="width: 100%; padding: 10px; background: rgba(255, 255, 255, 0.1); border: 1px solid var(--secondary); color: white; border-radius: 5px;">
        </div>
        
        <div>
            <label style="display: block; margin-bottom: 5px;">Email</label>
            <input type="email" name="email" required style="width: 100%; padding: 10px; background: rgba(255, 255, 255, 0.1); border: 1px solid var(--secondary); color: white; border-radius: 5px;">
        </div>
        
        <div>
            <label style="display: block; margin-bottom: 5px;">Пароль</label>
            <input type="password" name="password" required style="width: 100%; padding: 10px; background: rgba(255, 255, 255, 0.1); border: 1px solid var(--secondary); color: white; border-radius: 5px;">
        </div>
        
        <button type="submit" class="btn" style="width: 100%;">Зарегистрироваться</button>
    </form>
</div>
{% endblock %}

# DASHBOARD
{% extends "base.html" %}

{% block title %}Личный кабинет | Minerals Ural {% endblock %}

{% block styles %}
<style>
    .user-dashboard {
        max-width: 800px;
        margin: 50px auto;
        background: rgba(255, 255, 255, 0.1);
        padding: 30px;
        border-radius: 10px;
    }
    
    .user-info {
        margin-top: 30px;
    }
    
    .info-card {
        background: rgba(0, 0, 0, 0.3);
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
    }
    
    #userId {
        display: none;
        margin-top: 10px;
        padding: 15px;
        background: rgba(0, 0, 0, 0.5);
        border-left: 3px solid var(--secondary);
    }
    
    .id-btn {
        background: var(--secondary);
        color: var(--dark);
        border: none;
        padding: 10px 20px;
        border-radius: 5px;
        cursor: pointer;
        font-weight: 700;
        transition: 0.3s;
    }
    
    .id-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
    }
</style>
{% endblock %}

{% block content %}
<div class="user-dashboard fade-in">
    <h1 style="color: var(--secondary);">Добро пожаловать, <span style="text-transform: uppercase;">{{ user.username }}</span>!</h1>
    <p>Благодарим за доверие к компании Minerals Ural Mining</p>
    
    <div class="user-info">
        <div class="info-card">
            <h3 style="color: var(--secondary); margin-bottom: 10px;">Ваши данные</h3>
            <p><strong>Email:</strong> {{ user.email }}</p>
            
            <button class="id-btn" onclick="showUserId()">Показать мой ID</button>
            <div id="userId">
                Ваш уникальный идентификатор: <strong>{{ user.id }}</strong>
            </div>
        </div>
        
        <div class="info-card">
            <h3 style="color: var(--secondary); margin-bottom: 10px;">Статус аккаунта</h3>
            <p>✅ Аккаунт подтверждён</p>
            <p>🔄 Доступ к данным геологоразведки: <strong>открыт</strong></p>
        </div>
    </div>
</div>

<script>
    function showUserId() {
        const elem = document.getElementById('userId');
        elem.style.display = elem.style.display === 'none' ? 'block' : 'none';
    }
</script>
{% endblock %}



