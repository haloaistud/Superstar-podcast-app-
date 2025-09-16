import mongoose from 'mongoose';
const PodcastSchema = new mongoose.Schema({
  title: String,
  description: String,
  audioUrl: String,
  tags: [String],
  publishedAt: { type: Date, default: Date.now }
});
export default mongoose.model('Podcast', PodcastSchema);
