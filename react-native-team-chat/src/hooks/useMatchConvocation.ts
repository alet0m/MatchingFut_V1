import { useCallback, useEffect, useState } from 'react';
import { createMatchConvocation, getMatchParticipants } from '../lib/matches';
import type { MatchParticipant } from '../types/models';

export function useMatchConvocation(matchId: string, teamId: string) {
  const [participants, setParticipants] = useState<MatchParticipant[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const rows = await getMatchParticipants(matchId, teamId);
      setParticipants(rows);
    } catch (e: any) {
      setError(e.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }, [matchId, teamId]);

  const convoke = useCallback(async () => {
    try {
      await createMatchConvocation(matchId, teamId);
      await load();
    } catch (e) {
      throw e;
    }
  }, [matchId, teamId, load]);

  useEffect(() => {
    load();
  }, [load]);

  return { participants, loading, error, convoke, refetch: load };
}
