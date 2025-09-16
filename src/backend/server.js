import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import mongoose from 'mongoose';

dotenv.config();
const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, { cors: { origin: "*" } });

app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());

mongoose.connect(process.env.DB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
.then(() => console.log('MongoDB connected'))
.catch(err => console.error(err));

io.on('connection', (socket) => {
  console.log('WebSocket connected:', socket.id);
  socket.on('joinRoom', (room) => socket.join(room));
});

app.get('/', (req,res)=> res.send('Superstar Podcast Hub Backend Running'));

httpServer.listen(process.env.PORT || 3000, () => console.log('Server running on port', process.env.PORT || 3000));
