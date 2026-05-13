import '../models/question_model.dart';

// Bảng tra cứu câu hỏi theo Unit ID (Mỗi Unit 10 câu)
final Map<int, List<QuestionModel>> mockQuestionsByUnit = {

  // ================= UNIT 1: CHÀO HỎI & LÀM QUEN =================
  1: [
    QuestionModel(id: 'q1_1', unitId: 1, type: QuestionType.multipleChoice, questionText: "Từ nào có nghĩa là 'Giới thiệu'?", correctAnswer: "Introduce", options: ["Introduce", "Interview", "Internet", "Inside"]),
    QuestionModel(id: 'q1_2', unitId: 1, type: QuestionType.typing, questionText: "Họ (tên) tiếng Anh là gì?", correctAnswer: "Surname", options: []),
    QuestionModel(id: 'q1_3', unitId: 1, type: QuestionType.listening, questionText: "Nationality", correctAnswer: "Quốc tịch", options: ["Quốc tịch", "Quốc gia", "Thành phố", "Ngôn ngữ"]),
    QuestionModel(id: 'q1_4', unitId: 1, type: QuestionType.arrange, questionText: "Sắp xếp: 'Rất vui được gặp bạn'", correctAnswer: ["Nice", "to", "meet", "you"], options: ["you", "Nice", "see", "meet", "to"]),
    QuestionModel(id: 'q1_5', unitId: 1, type: QuestionType.multipleChoice, questionText: "Từ 'Neighbor' nghĩa là gì?", correctAnswer: "Hàng xóm", options: ["Người lạ", "Bạn bè", "Hàng xóm", "Đồng nghiệp"]),
    QuestionModel(id: 'q1_6', unitId: 1, type: QuestionType.arrange, questionText: "Sắp xếp: 'Biệt danh của tôi là Cat'", correctAnswer: ["My", "nickname", "is", "Cat"], options: ["is", "Cat", "name", "My", "nickname"]),
    QuestionModel(id: 'q1_7', unitId: 1, type: QuestionType.listening, questionText: "Stranger", correctAnswer: "Người lạ", options: ["Người quen", "Người lạ", "Sức mạnh", "Đường phố"]),
    QuestionModel(id: 'q1_8', unitId: 1, type: QuestionType.typing, questionText: "Địa chỉ (tiếng Anh là gì?)", correctAnswer: "Address", options: []),
    QuestionModel(id: 'q1_9', unitId: 1, type: QuestionType.multipleChoice, questionText: "Hành động 'Shake hands' là gì?", correctAnswer: "Bắt tay", options: ["Vẫy tay", "Bắt tay", "Ôm", "Cúi chào"]),
    QuestionModel(id: 'q1_10', unitId: 1, type: QuestionType.arrange, questionText: "Sắp xếp: 'Hẹn gặp lại bạn sau'", correctAnswer: ["See", "you", "later"], options: ["later", "See", "you", "meet", "soon"]),
  ],

  // ================= UNIT 2: THỜI TIẾT =================
  2: [
    QuestionModel(id: 'q2_1', unitId: 2, type: QuestionType.multipleChoice, questionText: "Thời tiết 'Ẩm ướt' là gì?", correctAnswer: "Humid", options: ["Humid", "Human", "Hot", "Heat"]),
    QuestionModel(id: 'q2_2', unitId: 2, type: QuestionType.listening, questionText: "Forecast", correctAnswer: "Dự báo", options: ["Dự báo", "Rừng cây", "Cơn bão", "Phía trước"]),
    QuestionModel(id: 'q2_3', unitId: 2, type: QuestionType.arrange, questionText: "Sắp xếp: 'Hôm nay trời nắng'", correctAnswer: ["It", "is", "sunny", "today"], options: ["sun", "It", "sunny", "today", "is"]),
    QuestionModel(id: 'q2_4', unitId: 2, type: QuestionType.typing, questionText: "Nhiệt độ (tiếng Anh là gì?)", correctAnswer: "Temperature", options: []),
    QuestionModel(id: 'q2_5', unitId: 2, type: QuestionType.multipleChoice, questionText: "Mùa nào lá thường rụng?", correctAnswer: "Autumn", options: ["Spring", "Summer", "Autumn", "Winter"]),
    QuestionModel(id: 'q2_6', unitId: 2, type: QuestionType.arrange, questionText: "Sắp xếp: 'Đừng quên cây dù'", correctAnswer: ["Do not", "forget", "the", "umbrella"], options: ["umbrella", "the", "forget", "Do not", "rain"]),
    QuestionModel(id: 'q2_7', unitId: 2, type: QuestionType.listening, questionText: "Stormy", correctAnswer: "Có bão", options: ["Có nắng", "Có bão", "Có tuyết", "Có gió"]),
    QuestionModel(id: 'q2_8', unitId: 2, type: QuestionType.typing, questionText: "Áo mưa (tiếng Anh là gì?)", correctAnswer: "Raincoat", options: []),
    QuestionModel(id: 'q2_9', unitId: 2, type: QuestionType.multipleChoice, questionText: "'Freezing' nghĩa là gì?", correctAnswer: "Lạnh cóng", options: ["Mát mẻ", "Lạnh cóng", "Đóng băng", "Nóng bức"]),
    QuestionModel(id: 'q2_10', unitId: 2, type: QuestionType.arrange, questionText: "Sắp xếp: 'Khí hậu thì nhiệt đới'", correctAnswer: ["The", "climate", "is", "tropical"], options: ["is", "The", "climate", "tropical", "hot"]),
  ],

  // ================= UNIT 3: THỜI GIAN =================
  3: [
    QuestionModel(id: 'q3_1', unitId: 3, type: QuestionType.multipleChoice, questionText: "Khoảng thời gian 100 năm?", correctAnswer: "Century", options: ["Decade", "Century", "Millennium", "Year"]),
    QuestionModel(id: 'q3_2', unitId: 3, type: QuestionType.listening, questionText: "Schedule", correctAnswer: "Lịch trình", options: ["Trường học", "Lịch trình", "Kỹ năng", "Thước đo"]),
    QuestionModel(id: 'q3_3', unitId: 3, type: QuestionType.arrange, questionText: "Sắp xếp: 'Tôi đi ngủ lúc nửa đêm'", correctAnswer: ["I", "go to", "bed", "at", "midnight"], options: ["midnight", "at", "go to", "I", "bed"]),
    QuestionModel(id: 'q3_4', unitId: 3, type: QuestionType.typing, questionText: "Cuối tuần (tiếng Anh là gì?)", correctAnswer: "Weekend", options: []),
    QuestionModel(id: 'q3_5', unitId: 3, type: QuestionType.multipleChoice, questionText: "'Immediately' nghĩa là gì?", correctAnswer: "Ngay lập tức", options: ["Thỉnh thoảng", "Ngay lập tức", "Gần đây", "Từ từ"]),
    QuestionModel(id: 'q3_6', unitId: 3, type: QuestionType.arrange, questionText: "Sắp xếp: 'Bây giờ là 3 giờ 15'", correctAnswer: ["It is", "a", "quarter", "past", "three"], options: ["three", "quarter", "past", "It is", "a"]),
    QuestionModel(id: 'q3_7', unitId: 3, type: QuestionType.listening, questionText: "Calendar", correctAnswer: "Lịch", options: ["Lịch", "Máy tính", "Bàn phím", "Danh sách"]),
    QuestionModel(id: 'q3_8', unitId: 3, type: QuestionType.typing, questionText: "Cuộc hẹn (tiếng Anh là gì?)", correctAnswer: "Appointment", options: []),
    QuestionModel(id: 'q3_9', unitId: 3, type: QuestionType.multipleChoice, questionText: "Người luôn đúng giờ là người?", correctAnswer: "Punctual", options: ["Late", "Punctual", "Early", "Lazy"]),
    QuestionModel(id: 'q3_10', unitId: 3, type: QuestionType.arrange, questionText: "Sắp xếp: 'Chúng tôi dậy lúc bình minh'", correctAnswer: ["We", "woke up", "at", "dawn"], options: ["at", "We", "dawn", "woke up", "sun"]),
  ],

  // ================= UNIT 4: MUA SẮM =================
  4: [
    QuestionModel(id: 'q4_1', unitId: 4, type: QuestionType.multipleChoice, questionText: "Người tính tiền tại quầy gọi là?", correctAnswer: "Cashier", options: ["Customer", "Cashier", "Manager", "Staff"]),
    QuestionModel(id: 'q4_2', unitId: 4, type: QuestionType.listening, questionText: "Receipt", correctAnswer: "Hóa đơn", options: ["Công thức", "Hóa đơn", "Nhận lấy", "Tiền lẻ"]),
    QuestionModel(id: 'q4_3', unitId: 4, type: QuestionType.typing, questionText: "Đắt tiền (trái nghĩa với Cheap)", correctAnswer: "Expensive", options: []),
    QuestionModel(id: 'q4_4', unitId: 4, type: QuestionType.arrange, questionText: "Sắp xếp: 'Cái này quá đắt'", correctAnswer: ["This", "is", "too", "expensive"], options: ["expensive", "too", "This", "is", "cheap"]),
    QuestionModel(id: 'q4_5', unitId: 4, type: QuestionType.multipleChoice, questionText: "Hành động trả giá để mua rẻ hơn?", correctAnswer: "Bargain", options: ["Purchase", "Refund", "Bargain", "Discount"]),
    QuestionModel(id: 'q4_6', unitId: 4, type: QuestionType.arrange, questionText: "Sắp xếp: 'Phòng thử đồ ở đâu?'", correctAnswer: ["Where", "is", "the", "fitting room"], options: ["room", "fitting", "Where", "the", "is", "room"]),
    QuestionModel(id: 'q4_7', unitId: 4, type: QuestionType.listening, questionText: "Discount", correctAnswer: "Giảm giá", options: ["Tăng giá", "Giảm giá", "Miễn phí", "Hết hàng"]),
    QuestionModel(id: 'q4_8', unitId: 4, type: QuestionType.typing, questionText: "Ví tiền (tiếng Anh là gì?)", correctAnswer: "Wallet", options: []),
    QuestionModel(id: 'q4_9', unitId: 4, type: QuestionType.multipleChoice, questionText: "Khi trả lại hàng, bạn nhận được gì?", correctAnswer: "Refund", options: ["Receipt", "Refund", "Discount", "Gift"]),
    QuestionModel(id: 'q4_10', unitId: 4, type: QuestionType.arrange, questionText: "Sắp xếp: 'Bạn có thẻ tín dụng không?'", correctAnswer: ["Do", "you", "have", "a", "credit card"], options: ["card", "credit", "have", "Do", "you", "a"]),
  ],

  // ================= UNIT 5: THỂ THAO =================
  5: [
    QuestionModel(id: 'q5_1', unitId: 5, type: QuestionType.multipleChoice, questionText: "Người huấn luyện đội bóng?", correctAnswer: "Coach", options: ["Referee", "Coach", "Athlete", "Captain"]),
    QuestionModel(id: 'q5_2', unitId: 5, type: QuestionType.listening, questionText: "Victory", correctAnswer: "Chiến thắng", options: ["Thất bại", "Chiến thắng", "Hòa", "Giải đấu"]),
    QuestionModel(id: 'q5_3', unitId: 5, type: QuestionType.arrange, questionText: "Sắp xếp: 'Bơi lội tốt cho sức khỏe'", correctAnswer: ["Swimming", "is", "good", "for", "health"], options: ["health", "good", "for", "Swimming", "is", "bad"]),
    QuestionModel(id: 'q5_4', unitId: 5, type: QuestionType.typing, questionText: "Sân vận động (tiếng Anh là gì?)", correctAnswer: "Stadium", options: []),
    QuestionModel(id: 'q5_5', unitId: 5, type: QuestionType.multipleChoice, questionText: "Người thi đấu đối đầu với bạn?", correctAnswer: "Opponent", options: ["Teammate", "Opponent", "Audience", "Fan"]),
    QuestionModel(id: 'q5_6', unitId: 5, type: QuestionType.arrange, questionText: "Sắp xếp: 'Chúng tôi đã thắng giải đấu'", correctAnswer: ["We", "won", "the", "tournament"], options: ["tournament", "won", "the", "We", "game"]),
    QuestionModel(id: 'q5_7', unitId: 5, type: QuestionType.listening, questionText: "Athlete", correctAnswer: "Vận động viên", options: ["Khán giả", "Vận động viên", "Huấn luyện viên", "Trọng tài"]),
    QuestionModel(id: 'q5_8', unitId: 5, type: QuestionType.typing, questionText: "Cơ bắp (tiếng Anh là gì?)", correctAnswer: "Muscle", options: []),
    QuestionModel(id: 'q5_9', unitId: 5, type: QuestionType.multipleChoice, questionText: "Người thổi còi trong trận đấu?", correctAnswer: "Referee", options: ["Coach", "Referee", "Player", "Manager"]),
    QuestionModel(id: 'q5_10', unitId: 5, type: QuestionType.arrange, questionText: "Sắp xếp: 'Tôi chạy bộ mỗi sáng'", correctAnswer: ["I", "go", "jogging", "every", "morning"], options: ["jogging", "morning", "go", "I", "every"]),
  ],

  // ================= UNIT 6: CÔNG VIỆC =================
  6: [
    QuestionModel(id: 'q6_1', unitId: 6, type: QuestionType.multipleChoice, questionText: "Tiền nhận được hàng tháng khi đi làm?", correctAnswer: "Salary", options: ["Bonus", "Salary", "Money", "Cash"]),
    QuestionModel(id: 'q6_2', unitId: 6, type: QuestionType.listening, questionText: "Colleague", correctAnswer: "Đồng nghiệp", options: ["Cao đẳng", "Đồng nghiệp", "Sếp", "Khách hàng"]),
    QuestionModel(id: 'q6_3', unitId: 6, type: QuestionType.arrange, questionText: "Sắp xếp: 'Tôi có một cuộc phỏng vấn'", correctAnswer: ["I", "have", "an", "interview"], options: ["interview", "a", "an", "have", "I"]),
    QuestionModel(id: 'q6_4', unitId: 6, type: QuestionType.typing, questionText: "Kinh nghiệm (tiếng Anh là gì?)", correctAnswer: "Experience", options: []),
    QuestionModel(id: 'q6_5', unitId: 6, type: QuestionType.multipleChoice, questionText: "Khi bạn già và ngừng làm việc hoàn toàn?", correctAnswer: "Retire", options: ["Resign", "Retire", "Fire", "Hire"]),
    QuestionModel(id: 'q6_6', unitId: 6, type: QuestionType.arrange, questionText: "Sắp xếp: 'Ký vào hợp đồng'", correctAnswer: ["Sign", "the", "contract"], options: ["contract", "the", "Sign", "paper"]),
    QuestionModel(id: 'q6_7', unitId: 6, type: QuestionType.listening, questionText: "Promotion", correctAnswer: "Thăng chức", options: ["Giáng chức", "Thăng chức", "Sa thải", "Tuyển dụng"]),
    QuestionModel(id: 'q6_8', unitId: 6, type: QuestionType.typing, questionText: "Hạn chót (tiếng Anh là gì?)", correctAnswer: "Deadline", options: []),
    QuestionModel(id: 'q6_9', unitId: 6, type: QuestionType.multipleChoice, questionText: "Người làm thuê gọi là gì?", correctAnswer: "Employee", options: ["Employer", "Employee", "Boss", "Director"]),
    QuestionModel(id: 'q6_10', unitId: 6, type: QuestionType.arrange, questionText: "Sắp xếp: 'Tuyển thêm nhân viên'", correctAnswer: ["Recruit", "more", "staff"], options: ["staff", "more", "Recruit", "hire"]),
  ],

  // ================= UNIT 7: HOẠT ĐỘNG HẰNG NGÀY =================
  7: [
    QuestionModel(id: 'q7_1', unitId: 7, type: QuestionType.multipleChoice, questionText: "Việc nhà tiếng Anh là gì?", correctAnswer: "Housework", options: ["Homework", "Housework", "Working", "Job"]),
    QuestionModel(id: 'q7_2', unitId: 7, type: QuestionType.listening, questionText: "Routine", correctAnswer: "Thói quen", options: ["Đường đi", "Thói quen", "Luật lệ", "Rễ cây"]),
    QuestionModel(id: 'q7_3', unitId: 7, type: QuestionType.arrange, questionText: "Sắp xếp: 'Tôi thức dậy lúc 6 giờ'", correctAnswer: ["I", "wake up", "at", "6", "o'clock"], options: ["wake up", "at", "I", "on", "6", "o'clock"]),
    QuestionModel(id: 'q7_4', unitId: 7, type: QuestionType.typing, questionText: "Giặt ủi (tiếng Anh là gì?)", correctAnswer: "Laundry", options: []),
    QuestionModel(id: 'q7_5', unitId: 7, type: QuestionType.multipleChoice, questionText: "Commute nghĩa là gì?", correctAnswer: "Đi lại (đi làm)", options: ["Giao tiếp", "Đi lại (đi làm)", "Cộng đồng", "Máy tính"]),
    QuestionModel(id: 'q7_6', unitId: 7, type: QuestionType.arrange, questionText: "Sắp xếp: 'Đánh răng hai lần'", correctAnswer: ["Brush", "teeth", "twice"], options: ["teeth", "twice", "Brush", "clean"]),
    QuestionModel(id: 'q7_7', unitId: 7, type: QuestionType.listening, questionText: "Relax", correctAnswer: "Thư giãn", options: ["Làm việc", "Thư giãn", "Căng thẳng", "Ngủ"]),
    QuestionModel(id: 'q7_8', unitId: 7, type: QuestionType.typing, questionText: "Rác thải (tiếng Anh là gì?)", correctAnswer: "Garbage", options: []),
    QuestionModel(id: 'q7_9', unitId: 7, type: QuestionType.multipleChoice, questionText: "Giấc ngủ ngắn vào buổi trưa?", correctAnswer: "Nap", options: ["Sleep", "Nap", "Dream", "Rest"]),
    QuestionModel(id: 'q7_10', unitId: 7, type: QuestionType.arrange, questionText: "Sắp xếp: 'Chuẩn bị bữa tối'", correctAnswer: ["Prepare", "dinner"], options: ["dinner", "Prepare", "make", "cook"]),
  ],

  // ================= UNIT 8: GIÁO DỤC =================
  8: [
    QuestionModel(id: 'q8_1', unitId: 8, type: QuestionType.multipleChoice, questionText: "Nơi chứa rất nhiều sách để đọc?", correctAnswer: "Library", options: ["Laboratory", "Library", "Bookstore", "Classroom"]),
    QuestionModel(id: 'q8_2', unitId: 8, type: QuestionType.listening, questionText: "Knowledge", correctAnswer: "Kiến thức", options: ["Biết", "Kiến thức", "Thông minh", "Sự thật"]),
    QuestionModel(id: 'q8_3', unitId: 8, type: QuestionType.arrange, questionText: "Sắp xếp: 'Cô ấy sẽ tốt nghiệp năm sau'", correctAnswer: ["She", "will", "graduate", "next", "year"], options: ["year", "next", "graduate", "will", "She", "is"]),
    QuestionModel(id: 'q8_4', unitId: 8, type: QuestionType.typing, questionText: "Học bổng (tiếng Anh là gì?)", correctAnswer: "Scholarship", options: []),
    QuestionModel(id: 'q8_5', unitId: 8, type: QuestionType.multipleChoice, questionText: "Người đứng đầu một trường học?", correctAnswer: "Principal", options: ["Teacher", "Student", "Principal", "Janitor"]),
    QuestionModel(id: 'q8_6', unitId: 8, type: QuestionType.arrange, questionText: "Sắp xếp: 'Cải thiện tiếng Anh của tôi'", correctAnswer: ["Improve", "my", "English"], options: ["my", "English", "Improve", "study"]),
    QuestionModel(id: 'q8_7', unitId: 8, type: QuestionType.listening, questionText: "Assignment", correctAnswer: "Bài tập được giao", options: ["Bài kiểm tra", "Bài tập được giao", "Chữ ký", "Đánh giá"]),
    QuestionModel(id: 'q8_8', unitId: 8, type: QuestionType.typing, questionText: "Đồng phục (tiếng Anh là gì?)", correctAnswer: "Uniform", options: []),
    QuestionModel(id: 'q8_9', unitId: 8, type: QuestionType.multipleChoice, questionText: "Trái nghĩa với 'Present' (Có mặt) là?", correctAnswer: "Absent", options: ["Late", "Absent", "Early", "Here"]),
    QuestionModel(id: 'q8_10', unitId: 8, type: QuestionType.arrange, questionText: "Sắp xếp: 'Mở sách giáo khoa ra'", correctAnswer: ["Open", "your", "textbook"], options: ["textbook", "your", "Open", "book"]),
  ],
};

// Hàm tiện ích để lấy data theo Unit
List<QuestionModel> getQuestionsForUnit(int unitId) {
  // Trả về danh sách câu hỏi của Unit, nếu không có thì trả về rỗng
  return mockQuestionsByUnit[unitId] ?? [];
}