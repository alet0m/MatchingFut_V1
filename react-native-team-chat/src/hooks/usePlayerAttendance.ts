import { useCallback, useState } from 'react';
import { setPlayerAttendance } from '../lib/matches';

export function usePlayerAttendance(matchId: string, playerId: string) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [summary, setSummary] = useState<{
    confirmedCount: number;
    minRequired: number;
    maxAllowed: number;
    atRisk: boolean;
    atCapacity: boolean;
  } | null>(null);

  const update = useCallback(async (status: 'pending' | 'confirmed' | 'declined') => {
    setLoading(true);
    setError(null);
    try {
      const s = await setPlayerAttendance(matchId, playerId, status);
      setSummary(s);
      return s;
    } catch (e: any) {
      setError(e.message ?? String(e));
      throw e;
    } finally {
      setLoading(false);
    }
  }, [matchId, playerId]);

  return { update, loading, error, summary };
}
