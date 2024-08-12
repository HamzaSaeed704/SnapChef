from flask import Flask, request, jsonify
import google.generativeai as genai
import google.ai.generativelanguage as glm
from PIL import Image
import os
import io
import base64

app = Flask(__name__)

genai.configure(api_key=os.getenv("GENAI_API_KEY"))
model = genai.GenerativeModel('gemini-1.5-flash')

@app.route('/', methods=['POST'])
def process_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})
    
    file = request.files['file']
    menu_type = request.form.get('menu_type')
    country = request.form.get('country')
    latitude = request.form.get('latitude')
    longitude = request.form.get('longitude')

    # Debugging: Print received location data
    print(f"Received latitude: {latitude}, longitude: {longitude}")

    if file.filename == '':
        return jsonify({'error': 'No selected file'})
    
    if file and menu_type:
        image = Image.open(file.stream)
        buffered = io.BytesIO()
        image.save(buffered, format="JPEG")
        img_str = base64.b64encode(buffered.getvalue()).decode()
        
        prompt = generate_prompt(menu_type, country, latitude, longitude)
        
        response = model.generate_content(
            glm.Content(
                parts=[
                    glm.Part(text=prompt),
                    glm.Part(
                        inline_data=glm.Blob(
                            mime_type='image/jpeg',
                            data=base64.b64decode(img_str)
                        )
                    ),
                ],
            ),
            stream=True
        )
        
        response.resolve()
        return jsonify({'recipe': response.text})

def generate_prompt(menu_type, country=None, latitude=None, longitude=None):
    base_prompt = "You are an expert chef (Your name is snapchef) but some people may only inquire about price or proteins. "
    location_info = f"The user is located in {country}. Their approximate coordinates are latitude {latitude}, longitude {longitude}. "
    
    menu_specific_prompts = {
        'Recipe Diagnostics': "Analyze the image and give step-by-step instructions on Tell what dish is in the image and its recipe (make headings for ingredients and recipe), tell how much time it will take cooking, also give link to a related YouTube video in which we learn how to make.",
        'Protein Calculator': f"{location_info}How much protein is there in the provided dish, considering local variants and portion sizes typical in {country}? Tell to the point (you can tell what's the protein weightage in the image and what's in 100 grams of it), even if it's an estimation, nothing else, highlight the protein weightage.",
        'Magic Dish': "Analyze the image and give step-by-step instructions on these are the things left in my kitchen, which dishes can I make from these and briefly tell how.",
        'Price Calculator': f"{location_info}Tell the average price of the thing in the image in {country}, stay to the point, nothing else, highlight the price. If the country is not specified, provide prices for both India and Pakistan.",
        'Food Finder': f"{location_info}Analyze the image and tell me where I can find this specific food item or dish nearby. Provide information on local restaurants or markets within a 5km radius of the given coordinates that might offer it. Also, suggest popular online food delivery platforms or websites where I could order this item for delivery in this specific area. Focus only on results relevant to the provided location."
    }
    
    return f"{base_prompt}{menu_specific_prompts.get(menu_type, '')}"

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
