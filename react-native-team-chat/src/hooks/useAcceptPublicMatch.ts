import { useCallback, useState } from 'react';
import { acceptPublicMatch, type AcceptPublicMatchInput } from '../lib/matches';
import type { Match, PublicMatch } from '../types/models';

export function useAcceptPublicMatch() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<{ match: Match; public_match: PublicMatch } | null>(null);

  const mutate = useCallback(async (input: AcceptPublicMatchInput) => {
    setLoading(true);
    setError(null);
    try {
      const out = await acceptPublicMatch(input);
      setResult(out);
      return out;
    } catch (e: any) {
      setError(e.message ?? String(e));
      throw e;
    } finally {
      setLoading(false);
    }
  }, []);

  return { accept: mutate, loading, error, result };
}
