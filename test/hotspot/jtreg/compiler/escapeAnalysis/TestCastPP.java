import java.util.HashMap;
import java.util.Map;

public final class TestCastPP {
   private static class Node {
        private final String name;
        private final Node parent;
        private final Map<String, Node> children = new HashMap<>();

        private Node(String name, Node parent) {
            this.name = name;
            this.parent = parent;

            if (parent != null) {
                parent.children.put(name, this);
            }
        }

        public String getPath() {
           if (parent == null) {
                return name;	       
            }
            return name + "/" + parent.getPath();
	}
    }

   public String test(Node node) {
       if (node.parent == null) {
             return null;
       }
       String path = node.getPath();
       String module = null;
       if(node.parent != null)
         module = "module";	
       
       String str = module+"/";
       String pkg = path.length() < str.length() ? path : path.substring(str.length());
       return pkg.replaceAll("/", ".");
    }

    public TestCastPP(Node node) {
        this.node = node;
    }
    public Node node;
    public static void main(String[] args) {
		 String p = "/modules/java.xml/com/sun/org/apache/xpath/internal/www/xs/c2/opt/share/compiler";
		 String[] split = p.split("/");
		 Node current = new Node("modules", null);
		 for (String s : split) {		
		      Node n = new Node(s, current);
		      current = n;
		}
		TestCastPP castPP = new TestCastPP(current);
		for (int i = 0; i < 10000; i++) {
			if (i % 11 == 1 || i % 17 == 0) {
			  castPP.test(castPP.node.parent);
			} else {
				castPP.test(castPP.node);
			}
		 }
   }
}
