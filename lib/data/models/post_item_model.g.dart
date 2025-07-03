// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostItemAdapter extends TypeAdapter<PostItem> {
  @override
  final int typeId = 1;

  @override
  PostItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostItem(
      id: fields[0] as int,
      userInfo: fields[1] as UserModel,
      content: fields[2] as String?,
      images: (fields[3] as List?)?.cast<String>(),
      videoUrl: fields[4] as String?,
      likesCount: fields[5] as int,
      unLikesCount: fields[6] as int,
      commentsCount: fields[7] as int,
      postTypeAsIntInput:fields[8] as int,
      isLiked: fields[9] as bool,
      isUnliked: fields[10] as bool,
      timestampMillisecondsSinceEpochInput: fields[11] as int,
      categoryId: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PostItem obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userInfo)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.images)
      ..writeByte(4)
      ..write(obj.videoUrl)
      ..writeByte(5)
      ..write(obj.likesCount)
      ..writeByte(6)
      ..write(obj.unLikesCount)
      ..writeByte(7)
      ..write(obj.commentsCount)
      ..writeByte(8)
      ..write(obj._postTypeAsInt)
      ..writeByte(9)
      ..write(obj.isLiked)
      ..writeByte(10)
      ..write(obj.isUnliked)
      ..writeByte(11)
      ..write(obj._timestampMillisecondsSinceEpoch)
      ..writeByte(12)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
