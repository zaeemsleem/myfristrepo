# Stage 1: Build the Angular app
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Copy only package.json and package-lock.json to install dependencies
COPY package.json package-lock.json ./

# Install dependencies using npm ci (use npm install if you want)
RUN npm ci --silent

# Copy the rest of the application code
COPY . .

# Build the Angular app for production
RUN npm run build -- --output-path=dist/cloudchain-app --configuration=production --source-map=false

# Remove node_modules and unnecessary files after build
RUN rm -rf node_modules && rm -rf src && rm -rf e2e

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Remove the default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy the built Angular app from the build stage into the Nginx serving folder
COPY --from=build /app/dist/cloudchain-app/browser /usr/share/nginx/html

# Expose the port for Nginx
EXPOSE 80

# Command to run Nginx
CMD ["nginx", "-g", "daemon off;"]
