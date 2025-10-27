import Link from 'next/link';
import { createSupabaseServer } from '@/lib/supabase/server';
import { getCurrentUser } from '@/lib/auth';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';

export default async function ProjectsPage() {
  const user = await getCurrentUser();
  const supabase = await createSupabaseServer();

  // Fetch user's projects with document count
  const { data: projects } = await supabase
    .from('projects')
    .select('*, project_documents(count)')
    .eq('owner_id', user?.id)
    .order('created_at', { ascending: false });

  const projectsWithCount = projects?.map((p) => ({
    ...p,
    document_count: p.project_documents?.[0]?.count || 0,
  }));

  return (
    <div className="max-w-6xl">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">Mes Projets</h1>
          <p className="text-gray-600 mt-1">
            Gérez vos projets de préparation aux examens oraux
          </p>
        </div>
        <Link
          href="/projets/nouveau"
          className="px-5 py-2.5 bg-gray-900 text-white rounded-lg font-medium hover:bg-gray-800 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Créer un projet
        </Link>
      </div>

      {!projectsWithCount || projectsWithCount.length === 0 ? (
        <div className="bg-white rounded-xl border border-gray-200">
          <EmptyState
            title="Aucun projet pour l'instant"
            description="Créez votre premier projet pour commencer votre préparation"
          />
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {projectsWithCount.map((project) => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </div>
      )}
    </div>
  );
}

