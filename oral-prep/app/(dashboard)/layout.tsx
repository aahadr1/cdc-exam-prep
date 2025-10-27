import Sidebar from '@/components/Sidebar';
import Topbar from '@/components/Topbar';
import { getCurrentUser } from '@/lib/auth';

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const user = await getCurrentUser();

  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar />
      <div className="ml-64">
        <Topbar user={user} />
        <main className="p-8">
          {children}
        </main>
      </div>
    </div>
  );
}

