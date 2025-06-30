/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


class SessionTimeoutManager {
    constructor() {
        this.timeoutDuration = 30000; 
        this.timeoutId = null;
        this.isActive = true;
        
        this.init();
    }
    
    init() {

        if (this.isLoginPage()) {
            return;
        }
        

        const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'];
        
        events.forEach(event => {
            document.addEventListener(event, () => this.resetTimer(), true);
        });
        
        window.addEventListener('beforeunload', () => this.cleanup());
        
        // Iniciar el timer
        this.resetTimer();
        
        console.log('🔒 Sistema de timeout de sesión iniciado (30 segundos)');
    }
    
    isLoginPage() {
        return window.location.pathname.includes('login.jsp') || 
               document.title.includes('Iniciar Sesión');
    }
    
    resetTimer() {
        if (!this.isActive) return;
        
        if (this.timeoutId) {
            clearTimeout(this.timeoutId);
        }
        
        this.timeoutId = setTimeout(() => {
            this.handleTimeout();
        }, this.timeoutDuration);
    }
    
    handleTimeout() {
        if (!this.isActive) return;
        
        console.log('⏰ Tiempo de inactividad alcanzado, cerrando sesión...');
        
        this.isActive = false;
        
        this.showTimeoutMessage();
        
        this.performLogout();
    }
    
    showTimeoutMessage() {
        const message = document.createElement('div');
        message.innerHTML = '⏰ Sesión cerrada por inactividad';
        message.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background-color: #dc3545;
            color: white;
            padding: 15px 20px;
            border-radius: 5px;
            z-index: 10000;
            font-family: Arial, sans-serif;
            font-size: 14px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
        `;
        
        document.body.appendChild(message);
        
        setTimeout(() => {
            if (message.parentNode) {
                message.parentNode.removeChild(message);
            }
        }, 2000);
    }
    
    performLogout() {
        try {
            window.location.href = 'CerrarSesion';
        } catch (error) {
            console.error('Error al cerrar sesión:', error);
            
            fetch('CerrarSesion', {
                method: 'POST',
                credentials: 'same-origin'
            }).then(() => {
                window.location.href = 'login.jsp';
            }).catch(() => {
                // Método 3: Redirección directa a login como último recurso
                window.location.href = 'login.jsp';
            });
        }
    }
    
    cleanup() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId);
        }
        this.isActive = false;
    }
    
    pause() {
        this.isActive = false;
        if (this.timeoutId) {
            clearTimeout(this.timeoutId);
        }
        console.log('⏸️ Sistema de timeout pausado');
    }
    
    resume() {
        this.isActive = true;
        this.resetTimer();
        console.log('▶️ Sistema de timeout reanudado');
    }
}

document.addEventListener('DOMContentLoaded', function() {
    window.sessionManager = new SessionTimeoutManager();
});

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        if (!window.sessionManager) {
            window.sessionManager = new SessionTimeoutManager();
        }
    });
} else {
    if (!window.sessionManager) {
        window.sessionManager = new SessionTimeoutManager();
    }
}
