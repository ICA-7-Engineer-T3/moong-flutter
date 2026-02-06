/// Centralized Korean UI strings for the Moong app.
/// Extracted from hardcoded strings across 41 screen files.
class AppStrings {
  AppStrings._();

  // --- App ---
  static const String appTitle = 'Moong App';

  // --- Authentication ---
  static const String login = '로그인';
  static const String signup = '회원가입';
  static const String logout = '로그아웃';
  static const String logoutConfirm = '정말 로그아웃 하시겠습니까?';
  static const String cancel = '취소';
  static const String guest = 'Guest';

  // --- Navigation ---
  static const String goBack = '돌아가기';
  static const String garden = '정원';
  static const String settings = '설정';
  static const String feed = '먹이주기';
  static const String chat = '대화하기';
  static const String quest = '퀘스트';

  // --- Moong ---
  static const String startWithMoong = '뭉과 함께 시작하세요!';
  static String daysWithMoong(String name, int days) => '$name와 함께한 $days일';

  // --- Quest ---
  static const String todayQuest = '오늘의 퀘스트';
  static String questNumber(int index) => '퀘스트 $index';
  static String questSteps(int target) => '$target보';

  // --- Shop ---
  static const List<String> shopCategories = ['의류', '잡화', '가구', '배경', '시즌'];

  // --- Credits ---
  static const String credits = '크레딧';
  static const String heldCredits = '보유 크레딧';
  static const String creditsLabel = 'Credits';
  static const String charge = '충전하기';
  static const String recentHistory = '최근 사용 내역';

  // --- Settings ---
  static const String sound = 'Sound';
  static const String notification = 'Notification';
  static const String language = 'Language';
  static const String editProfile = 'Edit Profile';

  // --- Seed Data Shop Items ---
  static const String redHat = '빨간 모자';
  static const String blueShirt = '파란 티셔츠';
  static const String blackPants = '검은 바지';
  static const String sunglasses = '선글라스';
  static const String necklace = '목걸이';
  static const String watch = '시계';
  static const String smallDesk = '작은 책상';
  static const String comfyChair = '편안한 의자';
  static const String bookshelf = '책장';
  static const String forestBg = '숲 배경';
  static const String beachBg = '해변 배경';
  static const String spaceBg = '우주 배경';
  static const String sakuraBg = '벚꽃 배경';
  static const String christmasHat = '크리스마스 모자';
  static const String halloweenCostume = '할로윈 의상';
  static const String summerSwimsuit = '여름 수영복';

  // --- Credit History (mock data) ---
  static const String specialFoodPurchase = '특별한 음식 구매';
  static const String premiumBackground = '프리미엄 배경';
  static const String creditCharge = '크레딧 충전';
  static const String today = '오늘';
  static const String yesterday = '어제';
  static String daysAgo(int days) => '$days일 전';
}
