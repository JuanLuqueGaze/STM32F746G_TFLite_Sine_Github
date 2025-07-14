import numpy as np
import matplotlib.pyplot as plt

% Suponiendo que `S` es tu matriz de espectrograma
S = np.random.rand(100, 200)  % Reemplaza con tu matriz real

plt.imshow(S, aspect='auto', origin='lower', cmap='viridis')
plt.axis('off')  % Quita ejes si quieres una imagen limpia
plt.savefig('espectrograma.png', bbox_inches='tight', pad_inches=0)
plt.close()
