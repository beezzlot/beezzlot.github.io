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
