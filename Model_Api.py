from ultralytics import YOLO
from flask import Flask, request, jsonify,Response
import cv2
import os
import numpy as np
from pymongo import MongoClient
from datetime import datetime
from io import BytesIO
from PIL import Image
#Function To Save image 
def get_resulting_image(results):
  for r in results:
    im_array = r.plot()  # plot a BGR numpy array of predictions
    im = Image.fromarray(im_array[..., ::-1])  # RGB PIL image
    return im
# Initialize your YOLO model
model = YOLO("./yolov8n-kitti/train/weights/best.pt")

# Create a Flask application
app = Flask(__name__)

# MongoDB configuration
client = MongoClient("mongodb+srv://ridha:CDQ6HaF5_xNnV@karhabti.tn73nb9.mongodb.net/?retryWrites=true&w=majority")
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)
db = client["karhabti"]  # Replace with your database name
collection=db["photos"]
# Upload folder configuration
UPLOAD_FOLDER = r'D:\WafaMefteh\resultdeployement'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Function to save image and results in MongoDB
def save_to_mongodb(image_data, result_image):
    image_data["timestamp"] = datetime.now()
    image_data["result_image"] = result_image
    collection.insert_one(image_data)

@app.route('/detect_image', methods=['POST'])
def detect_image():
    if 'file' not in request.files:
        return jsonify({'error': 'Aucun fichier trouvé'}),400

    file = request.files['file']
    if file and allowed_file(file.filename):
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(image_path)

        # Perform YOLO detection and get the result image
        result_image = model.predict(image_path, save=False)  # Set save=False to get the result image
        image_PIL =get_resulting_image(result_image) 
        # Convert the PIL image to bytes
        image_bytes = BytesIO()
        image_PIL.save(image_bytes, format="PNG")
        image_data = image_bytes.getvalue()
        # Save the image and results in MongoDB
        image_real_data = {
            "image_path": image_path,
            "result_image_format": "png",  # You can change the format if needed
        }
        save_to_mongodb(image_real_data, image_data)

        return jsonify({'success': 'Image enregistrée et traitée avec succès'}),200
    else:
        return jsonify({'error': 'Extension de fichier non valide'}),400
@app.route('/get_image', methods=['GET'])
def get_image():
    image_path = request.args.get('image_path')  # Assuming the image_path is sent as a query parameter
    print(image_path)
    if not image_path:
        return jsonify({'error': 'Missing image_path parameter'}), 400

    # Query the MongoDB collection to find the document by image_path
    image_doc = collection.find_one({'image_path': image_path})

    if not image_doc:
        return jsonify({'error': 'Image not found'}), 404

    # Retrieve the image data from the document
    image_data = image_doc.get('result_image')

    if not image_data:
        return jsonify({'error': 'Image data not found'}), 404

    return Response(image_data, content_type='application/octet-stream')

def allowed_file(filename):
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

if __name__ == '__main__':
    app.run(debug=True)
