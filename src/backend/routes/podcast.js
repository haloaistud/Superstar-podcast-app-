import express from 'express';
import { uploadEpisode, getEpisodes } from '../controllers/podcastController.js';
const router = express.Router();

router.post('/upload', uploadEpisode);
router.get('/', getEpisodes);

export default router;
