import hfst
import re
import os
from fastapi import FastAPI, Query
from fastapi.staticfiles import StaticFiles

app = FastAPI(title="Kalaallisut Word Analyzer API")

# Pathing relative to this script's location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FST_PATH = os.path.join(SCRIPT_DIR, "analyser-gt-desc.hfst")
WEB_PATH = os.path.join(SCRIPT_DIR, "..", "static")

def load_fst():
    if not os.path.exists(FST_PATH):
        raise FileNotFoundError(f"Could not find HFST file at: {FST_PATH}")
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
    return {"word": word, "analyses": formatted_results}

# Serve Flutter frontend (must be last!)
if os.path.exists(WEB_PATH):
    app.mount("/", StaticFiles(directory=WEB_PATH, html=True), name="static")
else:
    print(f"Warning: Static web assets not found at {WEB_PATH}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)