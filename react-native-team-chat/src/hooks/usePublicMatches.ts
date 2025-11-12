import { useCallback, useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase';
import { listPublicMatches, type ListPublicMatchesFilters } from '../lib/matches';
import type { PublicMatch } from '../types/models';

type Row = PublicMatch;

export function usePublicMatches(initialFilters: ListPublicMatchesFilters = {}) {
  const [filters, setFilters] = useState<ListPublicMatchesFilters>(initialFilters);
  const [rows, setRows] = useState<Row[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const effectiveFilters = useMemo(() => ({
    ...filters,
    modality_type: filters.modality_type,
  }), [filters]);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await listPublicMatches(effectiveFilters);
      setRows(data);
    } catch (e: any) {
      setError(e.message ?? String(e));
    } finally {
      setLoading(false);
    }
  }, [effectiveFilters]);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    // Simple realtime: refresh on inserts/updates to public_matches
    const channel = supabase
      .channel('public_matches_feed')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'public_matches' }, () => {
        load();
      })
      .subscribe();
    return () => { supabase.removeChannel(channel); };
  }, [load]);

  return { rows, loading, error, setFilters, refetch: load };
}
