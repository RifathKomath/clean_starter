# WorkManager (used by better_player_plus) creates its Room database by reflection.
# Without this, R8 strips the generated constructor and the release app crashes on
# launch with: NoSuchMethodException: androidx.work.impl.WorkDatabase_Impl.<init>
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
