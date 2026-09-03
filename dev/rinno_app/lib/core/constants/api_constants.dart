// lib/core/constants/api_constants.dart
class ApiConstants {
  // URLs base
  static const String baseUrl = 'https://ferramentas.rinnovare.com.br';
  static const String recoveryUrl = 'https://rinnovare.com.br';
  
  // Endpoints de autenticação
  static const String loginEndpoint = '$baseUrl/log_in.php';
  static const String registerEndpoint = '$baseUrl/register.php';
  
  // Endpoints de recuperação de senha (API)
  static const String forgotPasswordEndpoint = '$baseUrl/forgot_password.php';
  static const String checkEmailEndpoint = '$baseUrl/check_email.php';
  
  // Endpoints de recuperação (WordPress REST API)
  static const String verifyResetTokenEndpoint = '$recoveryUrl/wp-json/rinnovare/v1/verify-token';
  static const String resetPasswordEndpoint = '$recoveryUrl/wp-json/rinnovare/v1/reset-password';
  static const String resetPasswordPage = '$recoveryUrl/reset-password/';
  
  // Endpoints de gerenciamento
  static const String getClientesEndpoint = '$baseUrl/get_clientes.php';
  static const String getUserItemsEndpoint = '$baseUrl/get_user_items.php';
  static const String addUserItemEndpoint = '$baseUrl/add_user_item.php';
  static const String removeItemEndpoint = '$baseUrl/remove_item.php';
  static const String updateItemEndpoint = '$baseUrl/update_item.php';

    // Endpoints de plantas
  static const String getUserPlantsEndpoint = '$baseUrl/get_user_plants.php';
  static const String getAllPlantsEndpoint = '$baseUrl/get_all_plants.php'; 
  static const String getPlantEndpoint = '$baseUrl/get_plant.php';
  static const String createPlantEndpoint = '$baseUrl/create_plant.php';
  static const String updatePlantEndpoint = '$baseUrl/update_plant.php';
  static const String deletePlantEndpoint = '$baseUrl/delete_plant.php';
  
  // Endpoints de status das plantas
  static const String getPlantStatusEndpoint = '$baseUrl/get_plant_status.php';
  static const String updatePlantStatusEndpoint = '$baseUrl/update_plant_status.php';
    
  // Cache keys
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String rememberMeKey = 'remember_me';
  static const String getAllUsersEndpoint = '$baseUrl/get_all_users.php'; 
}