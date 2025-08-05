// 감정 타입 정의
enum EmotionType {
  great('great', '아주 좋음'),
  good('good', '좋음'),
  okay('okay', '보통'),
  bad('bad', '안 좋음'),
  angry('angry', '화남'),
  terrible('terrible', '매우 안 좋음');

  const EmotionType(this.id, this.label);
  final String id;
  final String label;
} 