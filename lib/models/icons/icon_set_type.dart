// 아이콘 세트 정의
enum IconSetType {
  meboogi('meboogi', '메론빵'),
  shark('shark', '상어'),
  tomato('tomato', '토마토');

  const IconSetType(this.id, this.name);
  final String id;
  final String name;
} 