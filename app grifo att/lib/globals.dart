library grifo_app.globals;

const String baseUrl = 'https://teste-lab-prog-production.up.railway.app';
String currentUser = '';
String currentNome = '';
String currentTipo = '';
String sessionId = '';
void clearUserData() {
  currentUser = '';
  currentNome = '';
  currentTipo = '';
  sessionId = '';
}

bool isMaster() => currentTipo == 'MASTER';
bool isAdminOrMaster() => currentTipo == 'MASTER' || currentTipo == 'ADMIN';
bool canDelete() => currentTipo == 'MASTER';

