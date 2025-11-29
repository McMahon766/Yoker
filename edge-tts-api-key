from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse
from contextlib import asynccontextmanager
import edge_tts
import os
import uuid
from pathlib import Path

@asynccontextmanager
async def lifespan(app: FastAPI):
    Path("/tmp").mkdir(exist_ok=True)
    yield
    for f in Path("/tmp").glob("*.mp3"):
        try: f.unlink()
        except: pass

app = FastAPI(title="Edge-TTS API", version="1.0")

@app.post("/tts")
async def generate_tts(text: str, voice: str = "en-US-JennyNeural"):
    if not text or len(text) > 100000:
        raise HTTPException(400, "Invalid text length (max 100K chars)")
    
    file_id = uuid.uuid4().hex
    output_path = f"/tmp/{file_id}.mp3"
    
    try:
        comm = edge_tts.Communicate(text, voice)
        await comm.save(output_path)
        
        def cleanup(): 
            try: os.remove(output_path)
            except: pass
        
        return FileResponse(
            output_path,
            media_type="audio/mpeg",
            filename=f"tts_{file_id}.mp3",
            background=cleanup
        )
    except Exception as e:
        raise HTTPException(500, f"TTS generation failed: {str(e)[:100]}")

@app.get("/voices")
async def list_voices():
    try:
        voices = await edge_tts.list_voices()
        return {
            "voices": [{"name": v["Name"], "gender": v["Gender"], "locale": v["Locale"]} 
                      for v in voices],
            "count": len(voices)
        }
    except Exception as e:
        raise HTTPException(500, f"Failed to fetch voices: {str(e)[:100]}")

@app.get("/")
async def root():
    return {
        "service": "Edge-TTS API",
        "status": "operational",
        "version": "1.0",
        "endpoints": {
            "tts": "POST /tts?text=your_text&voice=en-US-JennyNeural",
            "voices": "GET /voices"
        }
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "edge-tts-api"}
