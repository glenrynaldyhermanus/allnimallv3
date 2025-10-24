# Instagram Gallery Feature - Quick Start Guide

## ⚡ Get Started in 5 Minutes

### Step 1: Run Database Migration (2 minutes)

1. Open [Supabase Dashboard](https://supabase.com/dashboard)
2. Go to your project → SQL Editor
3. Copy-paste contents of `database/instagram_gallery_migration.sql`
4. Click "Run"
5. Verify tables created:
   - `pet.photo_likes`
   - `pet.photo_comments`
   - `pet.photo_shares`
   - Updated `pet.pet_photos` with new columns

### Step 2: Configure Storage (1 minute)

1. In Supabase Dashboard → Storage
2. Click "Create bucket"
3. Name it: `pet-media`
4. Make it **Public**
5. Set file size limits (optional):
   ```
   Max file size: 50 MB
   Allowed MIME types: image/*, video/*
   ```

### Step 3: Install Dependencies (1 minute)

```bash
cd /Users/glen/Studios/Allnimall/allnimall_qr
flutter pub get
```

### Step 4: Run the App (30 seconds)

```bash
flutter run
```

### Step 5: Test the Feature (1 minute)

1. **Open Pet Profile** → Navigate to any pet
2. **Go to Gallery Tab** → Swipe to the gallery tab (4th tab, green icon)
3. **Upload Photo**:
   - Tap the **+** button
   - Select photo from gallery or take new one
   - Add caption: "My cute pet! 🐶"
   - Add hashtags: "cute", "dog", "love"
   - Tap **Upload**
4. **View Photo**:
   - Tap the uploaded photo
   - Swipe left/right to navigate
   - Pinch to zoom
5. **Like Photo**:
   - Tap the ❤️ icon
   - See count increase
6. **Add Comment**:
   - Tap 💬 icon
   - Enter your name (e.g., "John")
   - Type comment
   - Tap send
7. **Share Photo**:
   - Tap 🔗 icon
   - Choose "Copy Link"
   - See success message

## 🎯 That's It!

Your Instagram-style gallery is now fully functional with:

- ✅ Photo/video upload with compression
- ✅ Caption & hashtags
- ✅ Likes (with count)
- ✅ Comments (with name for anonymous users)
- ✅ Sharing (Instagram, Facebook, WhatsApp, Copy Link)
- ✅ Beautiful Instagram-style grid
- ✅ Full-screen viewer with swipe navigation

## 🐛 Troubleshooting

### "Bucket not found" error

→ Make sure you created the `pet-media` bucket in Supabase Storage

### "Failed to upload" error

→ Check Supabase Storage permissions (bucket should be public)

### Video thumbnail not showing

→ This is expected in development. Video thumbnails generate on first upload

### Like count not updating

→ Refresh the page by navigating away and back

### Comments not showing

→ Make sure you enter a name for anonymous comments

## 📞 Need Help?

Check these files:

- **Implementation Status**: `INSTAGRAM_GALLERY_IMPLEMENTATION_STATUS.md`
- **Complete Guide**: `IMPLEMENTATION_COMPLETE.md`
- **Database Migration**: `database/instagram_gallery_migration.sql`

## 🎉 You're Ready!

Start uploading photos and building your pet's Instagram-style gallery!
