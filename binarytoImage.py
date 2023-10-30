from PIL import Image
import io

# Replace 'input_file' with the path to your binary file
input_file = 'response.bin'

# Read the binary data from the file
with open(input_file, 'rb') as file:
    binary_data = file.read()

# Create a BytesIO object to work with binary data as a file
binary_stream = io.BytesIO(binary_data)

# Open the image using Pillow
image = Image.open(binary_stream)

# Display or save the image
image.show()  # This will display the image
# To save the image to a file, you can use image.save('output.png')
