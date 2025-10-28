-- Script para convertir posiciones de inglés a español en la base de datos
-- Esto es para actualizar los datos existentes que están en inglés

UPDATE profiles 
SET position = CASE 
  WHEN position = 'goalkeeper' THEN 'Portero'
  WHEN position = 'defender' THEN 'Defensa' 
  WHEN position = 'midfielder' THEN 'Mediocampo'
  WHEN position = 'forward' THEN 'Delantero'
  WHEN position = 'sin_posicion' THEN 'Mediocampo'
  ELSE position -- Mantener el valor si ya está en español o es otro valor
END
WHERE position IN ('goalkeeper', 'defender', 'midfielder', 'forward', 'sin_posicion');

-- Verificar los cambios
SELECT position, COUNT(*) as cantidad 
FROM profiles 
GROUP BY position
ORDER BY position;