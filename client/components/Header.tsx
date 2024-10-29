import Link from "next/link";
export default function Header() {
    return (
        <header className="sticky top-0 flex justify-center border-b bg-white">
            <div className="mx-auto flex h-16 w-full max-w-3xl items-center justify-between px-4 sm:px-6">
                <nav className="flex space-x-4">
                    <Link href="/viem_watch">
                        Viem监听
                    </Link>
                </nav>
            </div>
        </header>
    )
}
