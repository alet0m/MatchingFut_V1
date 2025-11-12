import { useState, useCallback } from 'react';
import { createPublicMatch, type CreatePublicMatchInput } from '../lib/matches';
import type { PublicMatch } from '../types/models';

export function useCreatePublicMatch() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [last, setLast] = useState<PublicMatch | null>(null);

  const mutate = useCallback(async (input: CreatePublicMatchInput) => {
    setLoading(true);
    setError(null);
    try {
      const pm = await createPublicMatch(input);
      setLast(pm);
      return pm;
    } catch (e: any) {
      setError(e.message ?? String(e));
      throw e;
    } finally {
      setLoading(false);
    }
  }, []);

  return { create: mutate, loading, error, last };
}
