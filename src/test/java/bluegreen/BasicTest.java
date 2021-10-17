package bluegreen;

import bluegreen.web.BlueGreenController;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.Arrays;
import java.util.stream.Collectors;

class BasicTest {

    @Test
    void load() {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        ctx.register(BlueGreenController.class);
        ctx.refresh();
        System.out.println(Arrays.stream(ctx.getBeanDefinitionNames()).collect(Collectors.joining(",")));
        BlueGreenController bean = ctx.getBean(BlueGreenController.class);
    }
}
