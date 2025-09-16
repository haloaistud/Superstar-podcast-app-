import { uploadAudio } from '../utils/storage.js';
import Podcast from '../models/podcastModel.js';

export const uploadEpisode = async (req,res)=>{
  res.json({ message: "Upload placeholder endpoint working" });
}

export const getEpisodes = async (req,res)=>{
  res.json([{ id:1, title:"Demo Episode", audioUrl:"https://example.com/audio.mp3"}]);
}
