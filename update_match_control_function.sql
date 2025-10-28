-- Función para actualizar el control de sectores cuando un partido termina
CREATE OR REPLACE FUNCTION public.update_sector_control()
RETURNS TRIGGER AS $$
DECLARE
    current_controller UUID;
    control_start_date TIMESTAMP WITH TIME ZONE;
    team_elo INTEGER;
    days_controlled INTEGER;
BEGIN
    -- Solo si el partido está completado, tiene sector, y tiene ganador
    IF NEW.status = 'completed' AND NEW.sector_id IS NOT NULL AND NEW.winner_id IS NOT NULL AND 
       (OLD.status != 'completed' OR OLD.winner_id IS NULL) THEN
        
        -- Obtener controlador actual y su fecha de inicio
        SELECT controlling_team_id, control_start_date INTO current_controller, control_start_date
        FROM public.sectors
        WHERE id = NEW.sector_id;
        
        -- Obtener ELO del equipo ganador
        SELECT elo_rating INTO team_elo
        FROM public.teams
        WHERE id = NEW.winner_id;
        
        -- Verificar si el ELO del ganador supera el umbral del sector
        IF team_elo >= (SELECT current_elo_threshold FROM public.sectors WHERE id = NEW.sector_id) THEN
            
            -- Si hay un controlador actual y es diferente al ganador
            IF current_controller IS NOT NULL AND current_controller != NEW.winner_id THEN
                -- Calcular días que controló el sector
                days_controlled := EXTRACT(DAY FROM (now() - control_start_date))::INTEGER;
                
                -- Registrar en el historial que el equipo anterior perdió el control
                INSERT INTO public.sector_control_history (
                    sector_id, team_id, control_start, control_end, 
                    elo_at_start, elo_at_end, total_days, match_id, loss_match_id
                )
                VALUES (
                    NEW.sector_id,
                    current_controller,
                    control_start_date,
                    now(),
                    (SELECT elo_rating FROM public.teams WHERE id = current_controller),
                    (SELECT elo_rating FROM public.teams WHERE id = current_controller),
                    days_controlled,
                    NULL, -- No tenemos el partido que le dio el control
                    NEW.id  -- Partido en que perdió el control
                );
            END IF;
            
            -- Actualizar sector con nuevo controlador
            UPDATE public.sectors
            SET 
                controlling_team_id = NEW.winner_id,
                control_start_date = now(),
                current_elo_threshold = team_elo, -- El nuevo umbral es el ELO del ganador
                total_matches = total_matches + 1,
                last_match_date = now(),
                updated_at = now()
            WHERE id = NEW.sector_id;
            
            -- Registrar nuevo control en el historial
            INSERT INTO public.sector_control_history (
                sector_id, team_id, control_start, elo_at_start, match_id
            )
            VALUES (
                NEW.sector_id,
                NEW.winner_id,
                now(),
                team_elo,
                NEW.id
            );
            
            -- Bonus de ELO por capturar un sector
            UPDATE public.teams
            SET elo_rating = elo_rating + 10 -- Pequeño bonus por capturar territorio
            WHERE id = NEW.winner_id;
            
            RETURN NEW;
        END IF;
        
        -- Siempre incrementar el contador de partidos del sector
        UPDATE public.sectors
        SET 
            total_matches = total_matches + 1,
            last_match_date = now(),
            updated_at = now()
        WHERE id = NEW.sector_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear o reemplazar el trigger
DROP TRIGGER IF EXISTS match_completed_sector_control ON public.matches;
CREATE TRIGGER match_completed_sector_control
    AFTER UPDATE ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION public.update_sector_control();