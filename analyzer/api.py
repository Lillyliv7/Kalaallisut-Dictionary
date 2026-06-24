import hfst
import re
import os
from fastapi import FastAPI, Query
from fastapi.responses import FileResponse
from typing import List

app = FastAPI(title="Kalaallisut Word Analyzer API")

FST_PATH = "analyser-gt-desc.hfst"
WEB_PATH = "static"


@app.get("/")
async def root():
    index_path = os.path.join(WEB_PATH, "index.html")
    return FileResponse(index_path)

def load_fst():
    in_stream = hfst.HfstInputStream(FST_PATH)
    analyzer = in_stream.read()
    in_stream.close()
    return analyzer

kal_analyzer = load_fst()

def clean_analysis(raw_string: str) -> str:
    cleaned = re.sub(r'@[^@]+@', '', raw_string)
    cleaned = cleaned.replace('_EPSILON_SYMBOL_', '')
    return cleaned

@app.get("/analyze")
async def analyze(word: str = Query(..., description="The Greenlandic word to analyze")):
    results = kal_analyzer.lookup(word)
    
    formatted_results = []
    for analysis, weight in results:
        formatted_results.append({
            "raw": analysis,
            "cleaned": clean_analysis(analysis),
            "weight": weight
        })
        
    return {
        "word": word,
        "analyses": formatted_results
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)