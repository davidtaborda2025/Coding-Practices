document.getElementById('btnLogin').addEventListener('click', () => {
    const user = document.getElementById('user').value.trim();
    const password = document.getElementById('pass').value;
    const button = document.getElementById('btnLogin');

    const msg = document.getElementById('msg');
    msg.style.opacity = "0";
    msg.classList.remove('shake-error');

    const fadeOutMsg = (seconds) => {
        setTimeout(() => {
            msg.style.opacity = "0";
            setTimeout(() => { msg.textContent = ''; }, 500);
        }, seconds * 1000);
    };

    setTimeout(() => {
        if (!user || !password) {
            msg.style.color = 'crimson';
            msg.textContent = 'Ingresa usuario y contraseña.';
            msg.style.opacity = "1";
            button.classList.add('shake-error');
            fadeOutMsg(3);
            return;
        }

        const VALID = { user: 'admin', password: 'secret' };

        if (user === VALID.user && password === VALID.password) {
            msg.style.color = 'limegreen';
            msg.textContent = 'Bienvenido. Autenticado correctamente.';
            msg.style.opacity = "1";
            fadeOutMsg(4);
        }
        else {
            msg.style.color = 'crimson';
            msg.textContent = 'Credenciales incorrectas.';
            msg.style.opacity = "1";
            button.classList.add('shake-error');
            fadeOutMsg(3);
        }
    }, 100);
});

const menu = document.getElementById('menu');
const hambIcon = document.getElementById('hambIcon');
const formContainer = document.querySelector('.form-container');

hambIcon.addEventListener('click', (e) => {
    e.stopPropagation();
    const isOpened = menu.classList.toggle('active');

    formContainer.classList.toggle('blur-effect', isOpened);
});

document.addEventListener('click', (e) => {
    if (menu.classList.contains('active') && !menu.contains(e.target) && e.target !== hambIcon) {
        menu.classList.remove('active');
        formContainer.classList.remove('blur-effect');
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && menu.classList.contains('active')) {
        menu.classList.remove('active');
        formContainer.classList.remove('blur-effect');
    }
});