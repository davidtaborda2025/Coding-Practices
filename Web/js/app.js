document.getElementById('btnLogin').addEventListener('click', async () => {
    const userValue = document.getElementById('user').value.trim();
    const passValue = document.getElementById('pass').value;
    const button = document.getElementById('btnLogin');

    const msg = document.getElementById('msg');
    msg.style.opacity = "0";
    button.classList.remove('shake-error');

    const fadeOutMsg = (seconds) => {
        setTimeout(() => {
            msg.style.opacity = "0";
            setTimeout(() => { msg.textContent = ''; }, 500);
        }, seconds * 1000);
    };

    if (!userValue || !passValue) {
        msg.style.color = 'crimson';
        msg.textContent = 'Ingresa usuario y contraseña.';
        msg.style.opacity = "1";
        button.classList.add('shake-error');
        fadeOutMsg(3);
        return;
    }

    try {
        const response = await fetch('http://localhost:5000/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user: userValue, pass: passValue })
        });

        const data = await response.json();

        if (response.ok && data.status === 'success') {
            msg.style.color = 'limegreen';
            msg.textContent = data.message;
            msg.style.opacity = "1";
            fadeOutMsg(4);
        }

        else {
            msg.style.color = 'crimson';
            msg.textContent = data.message;
            msg.style.opacity = "1";
            button.classList.add('shake-error');
            fadeOutMsg(3);
        }
    }

    catch (error) {
        msg.style.color = 'orange';
        msg.textContent = 'Error al conectar con la base de datos.';
        msg.style.opacity = "1";
        fadeOutMsg(3);
    }
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