import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (globals.sessionId.isNotEmpty) 'Cookie': globals.sessionId,
    };
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${globals.baseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(timeout);
      
      _extractSession(response);
      return response;
    } catch (e) {
      throw Exception('Erro ao fazer POST para $endpoint: $e');
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${globals.baseUrl}$endpoint');
    final response = await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(timeout);
    
    _extractSession(response);
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${globals.baseUrl}$endpoint');
    final response = await http.delete(
      url,
      headers: _getHeaders(),
    ).timeout(timeout);
    
    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${globals.baseUrl}$endpoint');
    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    ).timeout(timeout);
    
    return response;
  }

  static void _extractSession(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null && rawCookie.isNotEmpty) {
      int index = rawCookie.indexOf(';');
      globals.sessionId = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  static Future<Map<String, dynamic>> login(String login, String senha) async {
    try {
      final response = await post('/login', {'login': login, 'senha': senha});
      
      // Verifica o status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Erro no servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}'
      };
    }
  }

  /// Cadastro
  static Future<Map<String, dynamic>> cadastro(String nome, String login, String senha, String tipo) async {
    final response = await post('/cadastro', {
      'nome': nome,
      'login': login,
      'senha': senha,
      'tipo': tipo,
    });
    return jsonDecode(response.body);
  }

  /// Logout
  static Future<void> logout() async {
    await post('/logout', {});
  }

  /// Usuário atual
  static Future<Map<String, dynamic>> getUsuarioAtual() async {
    final response = await get('/usuario-atual');
    return jsonDecode(response.body);
  }

  // ==================== ENDPOINTS DE ESTOQUE ====================

  /// Listar itens de estoque
  static Future<List<dynamic>> getItensEstoque() async {
    final response = await get('/itens-estoque');
    return jsonDecode(response.body);
  }

  /// Cadastrar item de estoque
  static Future<Map<String, dynamic>> cadastrarItemEstoque(Map<String, dynamic> item) async {
    final response = await post('/itens-estoque', item);
    return jsonDecode(response.body);
  }

  /// Deletar item de estoque
  static Future<Map<String, dynamic>> deletarItemEstoque(int id) async {
    final response = await delete('/itens-estoque/$id');
    return jsonDecode(response.body);
  }

  /// Listar movimentações de estoque
  static Future<List<dynamic>> getMovimentacoesEstoque() async {
    final response = await get('/estoque');
    return jsonDecode(response.body);
  }

  /// Registrar movimentação de estoque
  static Future<Map<String, dynamic>> registrarMovimentacao(Map<String, dynamic> movimentacao) async {
    final response = await post('/form-estoque', movimentacao);
    return jsonDecode(response.body);
  }

  /// Deletar movimentação de estoque
  static Future<Map<String, dynamic>> deletarMovimentacao(int id) async {
    final response = await delete('/estoque/$id');
    return jsonDecode(response.body);
  }

  // ==================== ENDPOINTS DE CAUTELAS ====================

  /// Listar itens cauteláveis
  static Future<List<dynamic>> getItensCautela() async {
    final response = await get('/itens-cautela');
    return jsonDecode(response.body);
  }

  /// Cadastrar item cautelável
  static Future<Map<String, dynamic>> cadastrarItemCautela(Map<String, dynamic> item) async {
    final response = await post('/itens-cautela', item);
    return jsonDecode(response.body);
  }

  /// Deletar item cautelável
  static Future<Map<String, dynamic>> deletarItemCautela(int id) async {
    final response = await delete('/itens-cautela/$id');
    return jsonDecode(response.body);
  }

  /// Listar todas as cautelas
  static Future<List<dynamic>> getCautelas() async {
    final response = await get('/cautelas');
    return jsonDecode(response.body);
  }

  /// Listar minhas cautelas ativas
  static Future<List<dynamic>> getMinhasCautelas() async {
    final response = await get('/minhas-cautelas');
    return jsonDecode(response.body);
  }

  /// Listar cautelas ativas (quem está com)
  static Future<List<dynamic>> getCautelasAtivas() async {
    final response = await get('/cautelas-ativas');
    return jsonDecode(response.body);
  }

  /// Registrar cautela
  static Future<Map<String, dynamic>> registrarCautela(Map<String, dynamic> cautela) async {
    final response = await post('/form-cautela', cautela);
    return jsonDecode(response.body);
  }

  /// Devolver cautela
  static Future<Map<String, dynamic>> devolverCautela(int id) async {
    final response = await post('/devolver-cautela/$id', {});
    return jsonDecode(response.body);
  }

  /// Deletar cautela
  static Future<Map<String, dynamic>> deletarCautela(int id) async {
    final response = await delete('/cautelas/$id');
    return jsonDecode(response.body);
  }

  /// Quantidade cautelada por item
  static Future<int> getQuantidadeCautelada(int itemId) async {
    final response = await get('/cautelas-ativas-por-item/$itemId');
    return jsonDecode(response.body);
  }

  // ==================== ENDPOINTS DE GESTÃO (MASTER) ====================

  /// Listar cadastros pendentes
  static Future<List<dynamic>> getCadastrosPendentes() async {
    final response = await get('/cadastros-pendentes');
    return jsonDecode(response.body);
  }

  /// Aprovar cadastro
  static Future<Map<String, dynamic>> aprovarCadastro(int id) async {
    final response = await post('/aprovar-cadastro/$id', {});
    return jsonDecode(response.body);
  }

  /// Rejeitar cadastro
  static Future<Map<String, dynamic>> rejeitarCadastro(int id) async {
    final response = await post('/rejeitar-cadastro/$id', {});
    return jsonDecode(response.body);
  }

  /// Listar todos os usuários
  static Future<List<dynamic>> getUsuarios() async {
    final response = await get('/usuarios');
    return jsonDecode(response.body);
  }

  /// Deletar usuário
  static Future<Map<String, dynamic>> deletarUsuario(int id) async {
    final response = await delete('/usuarios/$id');
    return jsonDecode(response.body);
  }

  // ==================== ENDPOINTS DE LOG ====================

  /// Listar log de atividades
  static Future<List<dynamic>> getLogAtividades() async {
    final response = await get('/log-atividades');
    return jsonDecode(response.body);
  }
}

