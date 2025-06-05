class AppConfig {
  // Server Configuration
  static const String serverIp = "172.20.10.3"; // Updated IP
  static const int serverPort = 8000;
  static const String baseUrl = "http://$serverIp:$serverPort/";

  // API Endpoints
  static const String healthEndpoint = "/health";
  static const String processImageEndpoint = "/process_image";
  static const String analyzeSkinEndpoint = "/analyze_skin";
  static const String analyzeFaceEndpoint = "/analyze_face";
  static const String cameraStreamEndpoint = "/camera_stream";
  static const String modelInfoEndpoint = "/model_info";
  static const String depthEstimationEndpoint =
      "/process_depth"; // Verify this line exists

  // Default timeout duration
  static const Duration defaultTimeout = Duration(seconds: 30);

  // Current user and datetime (used across the app)
  static final DateTime currentDateTime = DateTime.parse('2025-03-04 17:43:27');
  static const String currentUser = 'surajgore-007';
}
